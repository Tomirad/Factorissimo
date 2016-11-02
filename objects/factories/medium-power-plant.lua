require 'lib/class'
require 'lib/explicit-global'
require 'lib/table-utils'
require 'objects/factories/factory'
local generate_layout = require 'objects/factories/layouts/generator'

MediumPowerPlant = class(Factory)
MediumPowerPlant.LAYOUT = generate_layout("medium")
MediumPowerPlant.CONFIG = require('config').medium_power_plant

function MediumPowerPlant:layout_factory()
    Factory.layout_factory(self) --do generic stuff first
end

function MediumPowerPlant:transfer_power()
    return Factory._transfer_power(self, self._power, self._entity)
end

return MediumPowerPlant
