require 'lib/class'
require 'lib/explicit-global'
require 'lib/table-utils'
require 'objects/factories/factory'
local generate_layout = require 'objects/factories/layouts/generator'

LargePowerPlant = class(Factory)
LargePowerPlant.LAYOUT = generate_layout("large")
LargePowerPlant.CONFIG = require('config').large_power_plant

function LargePowerPlant:layout_factory()
    Factory.layout_factory(self) --do generic stuff first
end

function LargePowerPlant:transfer_power()
    return Factory._transfer_power(self, self._power, self._entity)
end

return LargePowerPlant
