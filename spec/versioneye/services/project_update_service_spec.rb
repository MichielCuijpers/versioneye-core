require 'spec_helper'

describe ProjectUpdateService do

  describe 'update' do
    it 'will update the project' do
      user = UserFactory.create_new
      project = ProjectFactory.default user
      project.s3_filename = 'pom.xml'
      project.scm_fullname = 'versioneye/versioneye_maven_plugin'
      project.scm_branch = 'master'
      project.source = Project::A_SOURCE_GITHUB

      VCR.use_cassette('ProjectUpdateService_update', allow_playback_repeats: true) do
        project = described_class.update project
        project.should_not be_nil
        project.dependencies.count.should == 11
      end
    end
  end

  describe 'update_from_upload' do
    it 'updates an existing project from a file upload' do
      gemfile = "spec/fixtures/files/Gemfile"
      file_attachment = Rack::Test::UploadedFile.new(gemfile, "application/octet-stream")
      file = {'datafile' => file_attachment}

      user = UserFactory.create_new
      project = ProjectFactory.default user
      project.s3_filename = 'Gemfile'
      project.source = Project::A_SOURCE_UPLOAD
      project.save.should be_truthy
      Project.count.should == 1

      project = described_class.update_from_upload project, file, user
      project.should_not be_nil
      project.dependencies.count.should > 0
      Project.count.should == 1
    end
  end

end
