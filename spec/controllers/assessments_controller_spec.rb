require "rails_helper"

RSpec.describe AssessmentsController, type: :controller do
  
  before do
    @account = setup_lti_account
    @assessment = FactoryGirl.create(:assessment)

    allow(controller).to receive(:current_account).and_return(@account)
    allow(Account).to receive(:find_by).with(:lti_key).and_return(@account)

    @user = FactoryGirl.create(:user, account: @account)
    @external_identifier = FactoryGirl.create(:external_identifier, user: @user, identifier: "292832126") # identifier is from lti_params in support/lti.rb
    @lti_url = 'school.edu'
  end

  describe "show" do

    describe "LTI" do
      before do
        request.env['CONTENT_TYPE'] = "application/x-www-form-urlencoded"
      end

      describe "POST - correct params" do
        context "matching external identifier" do
          it "setups the user, logs them in and redirects" do
            params = lti_params({"launch_url" => assessment_url(@assessment) })
            params[:id] = @assessment.id
            post :show, params
            expect(response).to have_http_status(200)
            expect(assigns(:user)).to be
            expect(assigns(:user).email).to eq(params["lis_person_contact_email_primary"])
          end
        end
      end

      describe "POST - invalid params" do
        it "should return unauthorized status" do
          params = lti_params({"launch_url" => assessment_url(@assessment)})
          params[:context_title] = 'invalid'
          params[:id] = @assessment.id
          post :show, params
          expect(response).to have_http_status(401)
        end
      end
    end
  end

  context "logged in" do
    login_user
    describe "CREATE - Valid Params" do
      it "should return a valid assessment" do

        xml = File.new("#{Rails.root}/db/qti/assessment.xml")
        params = FactoryGirl.attributes_for(:assessment)
        params[:title] = 'Test'
        params[:description] = 'Test description'
        params[:xml_file] = xml
        params[:license] = 'test'
        post :create, assessment: params
        expect(response).to have_http_status(:ok)
      end  
    end
  end
  

end