require 'lib/class'
require 'lib/explicit-global'
require 'lib/table-utils'
require 'objects/factories/factory'
local generate_layout = require 'objects/factories/layouts/generator'

HugeFactory = class(Factory)
HugeFactory.LAYOUT = generate_layout("huge")
HugeFactory.CONFIG = require('config').huge_factory

function HugeFactory:layout_factory(room)
    Factory.layout_factory(self)
end

function HugeFactory:transfer_power()
    return Factory._transfer_power(self, self._entity, self._power)
end

return HugeFactory