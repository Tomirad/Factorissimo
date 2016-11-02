require 'lib/class'
require 'lib/explicit-global'
require 'lib/table-utils'

Factory = virtual_class()
Factory.ON_TICK = defines.events.on_tick
Factory.CONF_CONSTS = require('config').constants

function Factory:new(args)
    local params, layout = {}, self.LAYOUT
    params.game = args.game
    params.size = { width = layout.surface_width, height = layout.surface_height }
    params.chunk_radius = layout.chunk_radius
    params.exit_surface = args.entity.surface
    self._room = args.room or managers.room:create_room(params)
    self._connections = table.make_values_weak()
    self._entity = args.entity
    if not args.room then
        self:layout_factory(self._room)
    else
        self:_reconnect_room_entities()
    end
end


local function index_direction(dir)
	if dir == defines.direction.north then
		return "north"
	elseif dir == defines.direction.south then
		return "south"
	elseif dir == defines.direction.east then
		return "east"
	elseif dir == defines.direction.west then
		return "west"
	end
end

function Factory:deconstruct()
    for _,conn in pairs(self._connections) do
        conn:destroy_for_deconstruct(self._room.surface)
    end
end

function Factory:get_room()
    return self._room
end

function Factory:entity_valid()
    return self._entity.valid
end

function Factory:force()
    return self._entity.force
end

function Factory:layout_factory()
    self._room:set_tiles(self.LAYOUT.constructor.tiles)
	local force = self._entity.force
	for _, coords in pairs(self.LAYOUT.constructor.distributors) do
		local distrib = self._room:create_entity("factory-power-distributor", coords.x, coords.y, force)
		self._room:make_entity_permanent(distrib)
	end
	local dir = index_direction(self._entity.direction)
	local gate_dir = (self._entity.direction + 2) % 8
	for _, coords in pairs(self.LAYOUT[dir].gates) do
		local new_gate = self._room:create_entity("factory-gate", coords.x, coords.y, force, gate_dir)
		self._room:make_entity_permanent(new_gate)
	end
    local power = self._room:create_entity("factory-power-transferrer",
        self.LAYOUT.constructor.provider_x, self.LAYOUT.constructor.provider_y, force)
    self._room:make_entity_permanent(power)
    self._power = power
    self._inbox = self._room:create_entity("factory-chest-input", self.LAYOUT.constructor.input_chest_x,
        self.LAYOUT.constructor.input_chest_y, force)
    self._outbox = self._room:create_entity("factory-chest-output", self.LAYOUT.constructor.output_chest_x,
        self.LAYOUT.constructor.output_chest_y, force)
end

function Factory:_reconnect_room_entities()
    self._power = self._room:find_entity("factory-power-transferrer")
	local old_gate = self._room:find_entity("factory-gate")
	while old_gate do
		old_gate.destroy()
		old_gate = self._room:find_entity("factory-gate")
	end
	local force = self._entity.force
	local dir = index_direction(self._entity.direction)
	local gate_dir = (self._entity.direction + 2) % 8
	for _, coords in pairs(self.LAYOUT[dir].gates) do
		local new_gate = self._room:create_entity("factory-gate", coords.x, coords.y, force, gate_dir)
		self._room:make_entity_permanent(new_gate)
	end
end

function Factory:move_player_inside(player)
    local time, as_outside = self.CONFIG.time, self.CONF_CONSTS.SAME_AS_OUTSIDE
    self._room:set_daytime(time == as_outside and self._room:get_exit_surface().daytime or time,
        time ~= as_outside)
    self._room:player_enter_room(player, self:_get_entrance())
end

function Factory:move_player_outside(player)
    self._room:player_exit_room(player, self:_get_exit())
end

function Factory:transfer_power()
    error("Factory:transfer_power must be implemented in derived class")
end

function Factory:pollute_environment()
    if self:entity_valid() then
        self._room:transfer_pollution(self._entity.position, self.CONFIG.pollution_multiplier)
    end
end

function Factory:scan_for_connections(entity)
    if self:_try_make_virtual_connection(entity) then
        return
    end
    for i = 1, #self.LAYOUT.possible_connections do
        if self:entity_valid() and not self._connections[i] then
            local conn = self.LAYOUT.possible_connections[i]
            local px = self._entity.position.x + conn.outside_x
            local py = self._entity.position.y + conn.outside_y
            local room_surface = self._room:get_surface()
            local valid_dirs = { [conn.direction_in] = 1, [conn.direction_out] = 0 }
            local co = coroutine.create(self._try_find_connection_entity)
            coroutine.resume(co, self, i, self._entity.surface, room_surface,
                px, py, conn.inside_x, conn.inside_y, valid_dirs)
            coroutine.resume(co, room_surface, self._entity.surface,
                conn.inside_x, conn.inside_y, px, py)
        end
    end
end

function Factory:_get_entrance()
	local dir = index_direction(self._entity.direction)
    return self.LAYOUT[dir].entrance_x, self.LAYOUT[dir].entrance_y
end

function Factory:_get_exit()
	local dir = index_direction(self._entity.direction)
    local pos = self._entity.position
    return pos.x + self.LAYOUT[dir].exit_x, pos.y + self.LAYOUT[dir].exit_y
end

function Factory:_transfer_power(source, dest)
    if self:entity_valid() then
        local energy = math.min(source.energy, dest.electric_buffer_size - dest.energy)
        source.energy = source.energy - energy
        dest.energy = dest.energy + energy
    end
end

function Factory:_try_find_connection_entity(i, surface, target, x, y, in_x, in_y, valid_dirs)
    while true do
        local args = {}
        args.area = {{x - 0.2, y - 0.2}, {x + 0.2, y + 0.2}}
        args.force = self._entity.force
        local entities = surface.find_entities_filtered(args)
        if #entities > 0 then
            local dir, s_index, swap = valid_dirs[entities[1].direction], entities[1].surface.index, false 
            swap = (dir == 1 and s_index == self._room:get_index()) or
                (dir == 0 and s_index ~= self._room:get_index())
            self._connections[i] = managers.connection:try_connect(entities[1], target,
                in_x, in_y, valid_dirs, swap)
            return
        end
        surface, target, x, y, in_x, in_y = coroutine.yield()
    end
end

function Factory:_try_make_virtual_connection(entity)
    if entity and entity.valid and entity.type == "inserter" then
        managers.connection:try_connect(entity, {bldg = self._entity, inbox = self._inbox, outbox = self._outbox})
        return true
    end
end

function Factory:load()
    table.make_values_weak(self._connections)
end
