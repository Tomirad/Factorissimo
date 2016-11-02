require 'lib/class'
require 'lib/explicit-global'
require 'lib/table-utils'
require 'objects/factories/factory'
local generate_layout = require 'objects/factories/layouts/generator'

HugePowerPlant = class(Factory)
HugePowerPlant.LAYOUT = generate_layout("huge")
HugePowerPlant.CONFIG = require('config').huge_power_plant

function HugePowerPlant:layout_factory()
    Factory.layout_factory(self) --do generic stuff first
end

function HugePowerPlant:transfer_power()
    return Factory._transfer_power(self, self._power, self._entity)
end

return HugePowerPlant
