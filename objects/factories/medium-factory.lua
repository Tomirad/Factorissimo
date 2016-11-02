require 'lib/class'
require 'lib/explicit-global'
require 'lib/table-utils'
require 'objects/factories/factory'
local generate_layout = require 'objects/factories/layouts/generator'

MediumFactory = class(Factory)
MediumFactory.LAYOUT = generate_layout("medium")
MediumFactory.CONFIG = require('config').medium_factory

function MediumFactory:layout_factory(room)
    Factory.layout_factory(self)
end

function MediumFactory:transfer_power()
    return Factory._transfer_power(self, self._entity, self._power)
end

return MediumFactory