require 'rails_helper'

describe ActionComponent::Component do
  before(:each) do
    allow(ActionComponent::Component).to receive(:helper_vm_params).and_return({})
  end

  subject {
    ActionComponent::Component.new(component_path: '/user_list')
  }

  describe '#render' do
    it "utilizes the renderer" do
      mock_renderer = double()
      expect(subject).to receive(:renderer).and_return(mock_renderer)
      expect(mock_renderer).to receive(:render)

      subject.render()
    end
  end

  describe '#create_view_model' do
    it 'raises an error if VM does not inherits from ActionComponent::Component::ViewModel' do
      subject = ActionComponent::Component.new(component_path: '/invalid_vm')

      expect {
        subject.create_view_model()
      }.to raise_error(ActionComponent::Component::InvalidVMError, 'InvalidVm::ViewModel cannot be used as a ViewModel. Make sure that it inherits from ActionComponent::Component::ViewModel.')
    end

    it "returns a default instance if custom vm file doesn't exists" do
      subject = ActionComponent::Component.new(component_path: '/component_without_vm')
      expect(subject.create_view_model()).to be_an_instance_of(ActionComponent::Component::ViewModel)
    end

    it "merges vm with default data" do
      subject = ActionComponent::Component.new(component_path: '/component_without_vm')
      allow(subject).to receive(:view_model_default_data).and_return({ aditional: 'more'} )
      expect(subject.create_view_model.aditional).to eq('more')
    end

    it "searches for a constant with the vm path" do
      subject = ActionComponent::Component.new(component_path: '/with_vm')

      expect(subject.create_view_model()).to be_an_instance_of(WithVm::ViewModel)
    end

    it 'passes the data to the view model' do
      expect(ActionComponent::Component::ViewModel).to receive(:new).with(hash_including(number: 8, word: 'hi')).and_call_original
      subject = ActionComponent::Component.new(component_path: '/component_without_vm', view_model_data: { number: 8, word: 'hi' })
      vm = subject.create_view_model()
    end

    it 'passes helpers to the VM' do
      subject = ActionComponent::Component.new(component_path: '/component_without_vm')
      mock_helpers = double()
      expect(ActionComponent::Component).to receive(:helper_vm_params).and_return({
        h: mock_helpers
      })
      vm = subject.create_view_model()
      expect(vm.h).to be(mock_helpers)
    end
  end

  describe '#view_model_default_data' do
    it 'adds helper methods' do
      subject = ActionComponent::Component.new(component_path: '/component_without_vm')
      expect(subject.class).to receive(:helper_vm_params).and_return({ helper: 'existing' })
      expect(subject.view_model_default_data[:helper]).to eq('existing')
    end

    it 'adds lookup_context' do
      subject = ActionComponent::Component.new(component_path: '/component_without_vm')
      expect(subject).to receive(:lookup_context).and_return('existing' )
      expect(subject.view_model_default_data[:lookup_context]).to eq('existing')
    end
  end

  describe '#lookup_context' do
    it "setups a LookupContext according to the gem configuration" do
      allow(ActionComponent.configuration).to receive(:components_path).and_return('mockpath')
      expect(subject.lookup_context.view_paths.first.to_s).to match(/mockpath$/)
    end
  end
end