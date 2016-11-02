require 'lib/class'
require 'lib/explicit-global'
require 'lib/table-utils'
require 'objects/factories/factory'
local generate_layout = require 'objects/factories/layouts/generator'

SmallPowerPlant = class(Factory)
SmallPowerPlant.LAYOUT = generate_layout("small")
SmallPowerPlant.CONFIG = require('config').small_power_plant

function SmallPowerPlant:layout_factory()
    Factory.layout_factory(self) --do generic stuff first
end

function SmallPowerPlant:transfer_power()
    return Factory._transfer_power(self, self._power, self._entity)
end

return SmallPowerPlant
