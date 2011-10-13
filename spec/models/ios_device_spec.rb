require 'spec_helper'

describe IosDevice do
  
  describe "registering a device for a user" do
    
    before(:each) do
      @login = mock_model(Login)
      @ios_device = IosDevice.new
    end
    
    context "when it's a new device" do
      context "and all required parameters are present" do
        it "should register the device for this user" do
          # make sure it's a new device
          IosDevice.stub_chain(:where, :first).and_return(nil)
        
          expect {
            IosDevice.make_sure_its_registered_and_assigned_to_user("original_udid", "ss_udid", @login)
          }.to change(IosDevice, :count).by(1)
        end
      end
      
      context "and no device UDID was given as a parameter" do
        it "shouldn't register the device" do
          expect {
            IosDevice.make_sure_its_registered_and_assigned_to_user(nil, nil, @login)
          }.not_to change(IosDevice, :count)
        end
      end
      
      context "and the user is missing from the parameters" do
        it "shouldn't register the device" do
          expect {
            IosDevice.make_sure_its_registered_and_assigned_to_user("original_udid", "ss_udid", nil)
          }.not_to change(IosDevice, :count)
        end
      end
    end
    
    context "when it's a device that's already registered" do
      it "should find the right device" do
        # make sure the system doesn't find the device easily, so it looks for it by both UDIDs
        IosDevice.stub_chain(:where, :first).and_return(nil)
        
        IosDevice.should_receive(:where).with(hash_including(:original_udid))
        IosDevice.should_receive(:where).with(hash_including(:ss_udid))
        
        IosDevice.make_sure_its_registered_and_assigned_to_user("original_udid", "ss_udid", @login)
      end
      
      it "should re-assign the device to the user if it belongs to another one" do
        another_user     = stub_model(Login)
        @ios_device.user = another_user
        IosDevice.stub_chain(:where, :first).and_return(@ios_device)
        
        @ios_device.should_receive(:update_attributes).with(hash_including(:user))
        
        IosDevice.make_sure_its_registered_and_assigned_to_user("original_udid", "ss_udid", @login)
      end
    end
    
  end
  
  describe "migrating device UDIDs" do
    
    context "when the old UDID is not available" do
      it "shouldn't do anything" do
        result = IosDevice.try_to_migrate_device_udids(nil, "new_ss_id")
        
        result.should be_nil
      end
    end
    
    context "when the new UDID is not available" do
      it "shouldn't do anything" do
        result = IosDevice.try_to_migrate_device_udids("original_udid", nil)
        
        result.should be_nil
      end
    end
    
    context "when both UDIDs are available" do
      it "should find the right device" do
        IosDevice.should_receive(:where).with(hash_including(:original_udid)).and_return([])
        
        IosDevice.try_to_migrate_device_udids("original_udid", "new_ss_id")
      end
      
      it "should store the new UDID" do
        ios_device = mock("ios_device")
        IosDevice.stub_chain(:where, :first).and_return(ios_device)
        
        ios_device.should_receive(:update_attributes).with(hash_including(:ss_udid))
        
        IosDevice.try_to_migrate_device_udids("original_udid", "new_ss_id")
      end
    end
    
  end
  
end
