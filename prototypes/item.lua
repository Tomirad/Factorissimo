local function create_building_item(name, order_flag)
	return {
		type = "item",
		name = name,
		icon = "__Factorissimo__/graphics/icons/" .. name .. ".png",
		flags = { "goes-to-quickbar" },
		subgroup = "production-machine",
		order = "y[factory]-" .. order_flag .. "[" .. name .. "]",
		place_result = name,
		stack_size = 10
	}
end

data:extend({
  create_building_item("small-factory", "a"),
  create_building_item("medium-factory", "b"),
  create_building_item("large-factory", "c"),
  create_building_item("huge-factory", "d"),
  {
    type = "item",
    name = "factory-power-transferrer",
    icon = "__base__/graphics/icons/accumulator.png",
    flags = {"hidden"},
    subgroup = "production-machine",
    order = "y[factory]-z[invisible]-a",
    place_result = "factory-power-transferrer",
    stack_size = 50
  },
  create_building_item("small-power-plant", "e"),
  create_building_item("medium-power-plant", "f"),
  create_building_item("large-power-plant", "g"),
  create_building_item("huge-power-plant", "h"),
  {
    type = "item",
    name = "factory-power-distributor",
    icon = "__base__/graphics/icons/substation.png",
    flags = {"hidden"},
    subgroup = "production-machine",
    order = "y[factory]-z[invisible]-b",
    place_result = "factory-power-distributor",
    stack_size = 50
  },
  {
	  type = "item",
	  name = "factory-chest-output",
	  icon = "__base__/graphics/icons/logistic-chest-passive-provider.png",
	  flags = {"hidden"},
	  subgroup = "logistic-network",
	  order = "y[factory]-z[invisible]-c",
	  place_result = "factory-chest-output",
	  stack_size = 50,
  },
  {
	  type = "item",
	  name = "factory-chest-input",
	  icon = "__base__/graphics/icons/logistic-chest-requester.png",
	  flags = {"hidden"},
	  subgroup = "logistic-network",
	  order = "y[factory]-z[invisible]-d",
	  place_result = "factory-chest-input",
	  stack_size = 50,
  },
  {
    type = "item",
    name = "factory-gate",
    icon = "__base__/graphics/icons/gate.png",
    flags = {"hidden"},
    subgroup = "production-machine",
    order = "y[factory]-z[invisible]-d",
    place_result = "factory-gate",
    stack_size = 50
  }
})