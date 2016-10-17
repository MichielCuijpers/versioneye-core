require 'spec_helper'

describe LwlPdfService do


  before(:each) do
    Plan.create_defaults
    @user = User.new({:fullname => 'Hans Tanz', :username => 'hanstanz',
      :email => 'hans@tanz.de', :password => 'password', :salt => 'salt',
      :terms => true, :datenerhebung => true})
    @user.save
    @orga = OrganisationService.create_new_for @user
    expect( @orga.save ).to be_truthy
  end


  describe 'process' do
    it 'processes a simple project' do
      lwl = LicenseWhitelist.new({:name => 'OkForMe', :organisation_id => @orga.ids})
      expect(lwl.save).to be_truthy

      prod_1  = ProductFactory.create_new 1
      project = ProjectFactory.create_new @user, nil, true, @orga
      project.organisation_id = @orga.ids
      project.license_whitelist_id = lwl.ids
      project.save
      dep_1   = ProjectdependencyFactory.create_new project, prod_1, true
      dep_1.license_caches = []
      dep_1.license_caches << LicenseCach.new({:name => 'MIT', :on_whitelist => true})
      dep_1.save

      expect( LwlPdfService.process(project, true, true, true) ).to_not be_nil
    end
  end


  describe 'process_all' do
    it 'processes N projects' do
      lwl = LicenseWhitelist.new({:name => 'OkForMe', :organisation_id => @orga.ids})
      expect(lwl.save).to be_truthy

      prod_1  = ProductFactory.create_new 1
      project = ProjectFactory.create_new @user
      project.organisation_id = @orga.ids
      project.license_whitelist_id = lwl.ids
      project.save
      project2 = ProjectFactory.create_new @user, {:user_id => @user.ids, :name => "test_2"}, true, @orga
      project2.license_whitelist_id = lwl.ids
      project2.save
      dep_1   = ProjectdependencyFactory.create_new project, prod_1, true
      dep_1.license_caches = []
      dep_1.license_caches << LicenseCach.new({:name => 'MIT', :on_whitelist => true})
      dep_1.save
      dep_2   = ProjectdependencyFactory.create_new project2, prod_1, true
      dep_2.license_caches = []
      dep_2.license_caches << LicenseCach.new({:name => 'MIT', :on_whitelist => true})
      dep_2.save

      projects = [project, project2]
      expect( LwlPdfService.process_all(projects, lwl, nil, true, true) ).to_not be_nil
    end
  end


  describe 'prepare_kids' do
    it 'preparse the kids' do
      lwl  = LicenseWhitelist.new({:name => 'OkForMe', :organisation_id => @orga.ids})
      expect(lwl.save).to be_truthy

      prod_1  = ProductFactory.create_new 1
      project = ProjectFactory.create_new @user
      parent  = ProjectFactory.create_new @user
      dep_1   = ProjectdependencyFactory.create_new project, prod_1, true
      dep_1.save

      project.parent_id = parent.ids
      project.organisation_id = @orga.ids
      project.save

      parent.organisation_id = @orga.ids
      parent.save

      expect(project.lwl_pdf_list).to be_nil

      kids = described_class.prepare_kids parent, false
      expect( kids ).to_not be_nil

      expect(kids.first.lwl_pdf_list[:unknown].count).to eq(1)
      expect(kids.first.lwl_pdf_list[:whitelisted].count).to eq(0)
      expect(kids.first.lwl_pdf_list[:violated].count).to eq(0)
    end
  end


  describe 'fill_dto' do

    it 'it fills the dto with an empty line' do
      lwl = LicenseWhitelist.new({:name => 'OkForMe', :organisation_id => @orga.ids})
      expect(lwl.save).to be_truthy

      prod_1  = ProductFactory.create_new 1
      project = ProjectFactory.create_new @user
      dep_1 = ProjectdependencyFactory.create_new project, prod_1, true
      dep_1.save

      expect(project.lwl_pdf_list).to be_nil
      described_class.fill_dto project, false

      expect(project.lwl_pdf_list[:unknown].count).to eq(1)
      expect(project.lwl_pdf_list[:whitelisted].count).to eq(0)
      expect(project.lwl_pdf_list[:violated].count).to eq(0)
    end

    it 'it fills the dto with 1 whitelisted line' do
      lwl  = LicenseWhitelist.new({:name => 'OkForMe', :organisation_id => @orga.id})
      expect(lwl.save).to be_truthy
      LicenseWhitelistService.add @orga, 'OkForMe', 'MIT'

      prod_1  = ProductFactory.create_new 1
      project = ProjectFactory.create_new @user, nil, true, @orga
      project.license_whitelist_id = lwl.id
      project.save

      dep_1 = ProjectdependencyFactory.create_new project, prod_1, true
      dep_1.license_caches = []
      dep_1.license_caches << LicenseCach.new({:name => 'MIT', :on_whitelist => true})
      dep_1.save

      expect(project.lwl_pdf_list).to be_nil
      described_class.fill_dto project, false

      expect(project.lwl_pdf_list[:unknown].count).to eq(0)
      expect(project.lwl_pdf_list[:whitelisted].count).to eq(1)
      expect(project.lwl_pdf_list[:violated].count).to eq(0)
    end

    it 'it fills the dto, only 1 dependency on the list because uniq contstraint!' do
      lwl = LicenseWhitelist.new({:name => 'OkForMe', :organisation_id => @orga.id})
      expect(lwl.save).to be_truthy
      LicenseWhitelistService.add @orga, 'OkForMe', 'MIT'

      prod_1    = ProductFactory.create_new 1
      project_1 = ProjectFactory.create_new @user, nil, true, @orga
      project_1.license_whitelist_id = lwl.id
      project_1.save

      dep_1 = ProjectdependencyFactory.create_new project_1, prod_1, true
      dep_1.license_caches = []
      dep_1.license_caches << LicenseCach.new({:name => 'MIT', :on_whitelist => true})
      dep_1.save

      project_2 = ProjectFactory.create_new @user, nil, true, @orga
      project_2.license_whitelist_id = lwl.id
      project_2.parent_id = project_1.id
      project_2.save

      dep_2 = ProjectdependencyFactory.create_new project_2, prod_1, true
      dep_2.license_caches = []
      dep_2.license_caches << LicenseCach.new({:name => 'MIT', :on_whitelist => true})
      dep_2.save

      expect(project_1.lwl_pdf_list).to be_nil
      described_class.fill_dto project_1, true

      expect(project_1.lwl_pdf_list[:unknown].count).to eq(0)
      expect(project_1.lwl_pdf_list[:whitelisted].count).to eq(1)
      expect(project_1.lwl_pdf_list[:violated].count).to eq(0)
    end


    it 'it fills the dto, 2 dependency on the list because not unique and not flatten!' do
      lwl = LicenseWhitelist.new({:name => 'OkForMe', :organisation_id => @orga.id})
      expect(lwl.save).to be_truthy
      LicenseWhitelistService.add @orga, 'OkForMe', 'MIT'

      prod_1    = ProductFactory.create_new 1
      project_1 = ProjectFactory.create_new @user, nil, true, @orga
      project_1.license_whitelist_id = lwl.id
      project_1.save

      dep_1 = ProjectdependencyFactory.create_new project_1, prod_1, true
      dep_1.license_caches = []
      dep_1.license_caches << LicenseCach.new({:name => 'MIT', :on_whitelist => true})
      dep_1.save

      project_2 = ProjectFactory.create_new @user, nil, true, @orga
      project_2.license_whitelist_id = lwl.id
      project_2.parent_id = project_1.id
      project_2.save

      prod_2  = ProductFactory.create_new 2
      dep_2 = ProjectdependencyFactory.create_new project_2, prod_2, true
      dep_2.license_caches = []
      dep_2.license_caches << LicenseCach.new({:name => 'MIT', :on_whitelist => true})
      dep_2.save

      expect(project_1.lwl_pdf_list).to be_nil
      described_class.fill_dto project_1, true

      expect(project_1.lwl_pdf_list[:unknown].count).to eq(0)
      expect(project_1.lwl_pdf_list[:whitelisted].count).to eq(2)
      expect(project_1.lwl_pdf_list[:violated].count).to eq(0)
    end

    it 'fils the dto with 2 lines from 1 dependency, because of dual license' do
      lwl  = LicenseWhitelist.new({:name => 'OkForMe', :organisation_id => @orga.id, :pessimistic_mode => true})
      expect(lwl.save).to be_truthy
      LicenseWhitelistService.add @orga, 'OkForMe', 'MIT'

      prod_1    = ProductFactory.create_new 1
      project_1 = ProjectFactory.create_new @user, nil, true, @orga
      project_1.license_whitelist_id = lwl.id
      project_1.save

      dep_1 = ProjectdependencyFactory.create_new project_1, prod_1, true
      dep_1.license_caches = []
      dep_1.license_caches << LicenseCach.new({:name => 'MIT', :on_whitelist => true})
      dep_1.license_caches << LicenseCach.new({:name => 'GPL-3.0', :on_whitelist => false})
      dep_1.save

      expect( project_1.lwl_pdf_list ).to be_nil
      described_class.fill_dto project_1, true

      expect(project_1.lwl_pdf_list[:unknown].count).to eq(0)
      expect(project_1.lwl_pdf_list[:whitelisted].count).to eq(1)
      expect(project_1.lwl_pdf_list[:violated].count).to eq(1)
      expect(project_1.lwl_pdf_list[:violated].first[:license]).to eq('GPL-3.0')
      expect(project_1.lwl_pdf_list[:whitelisted].first[:license]).to eq('MIT')
    end

    it 'fils the dto with 1 line from 1 dependency, dual license, but pessimistic_mode = true' do
      lwl  = LicenseWhitelist.new({:name => 'OkForMe', :organisation_id => @orga.ids, :pessimistic_mode => false})
      expect(lwl.save).to be_truthy
      LicenseWhitelistService.add @orga, 'OkForMe', 'MIT'

      prod_1    = ProductFactory.create_new 1
      project_1 = ProjectFactory.create_new @user, nil, true, @orga
      project_1.license_whitelist_id = lwl.id
      expect( project_1.save ).to be_truthy

      dep_1 = ProjectdependencyFactory.create_new project_1, prod_1, true
      dep_1.license_caches = []
      dep_1.license_caches << LicenseCach.new({:name => 'MIT', :on_whitelist => true})
      dep_1.license_caches << LicenseCach.new({:name => 'GPL-3.0', :on_whitelist => false})
      dep_1.save

      expect(project_1.lwl_pdf_list).to be_nil
      described_class.fill_dto project_1, true

      expect(project_1.lwl_pdf_list[:unknown].count).to eq(0)
      expect(project_1.lwl_pdf_list[:whitelisted].count).to eq(1)
      expect(project_1.lwl_pdf_list[:violated].count).to eq(0)
      expect(project_1.lwl_pdf_list[:whitelisted].first[:license]).to eq('MIT')
    end

  end

end
