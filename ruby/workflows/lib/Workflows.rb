require 'mongooz'
Mongooz.defaults(:db=>'workflows')

require 'workflows/workflow_base.rb'
require 'workflows/status/workflow_status.rb'

# pricing steps and factory
require 'workflows/steps/pricing/default.rb'
require 'workflows/steps/pricing/PricingStepOne.rb'
require 'workflows/steps/pricing/PricingStepTwo.rb'
require 'workflows/steps/pricing/PricingStepThree.rb'
require 'workflows/steps/pricing/factory.rb'

# this comes after all step files are pulled in, as it depends on everything else
require 'workflows/steps/workflows_steps.rb'

require 'workflows/workflow_objects.rb'
