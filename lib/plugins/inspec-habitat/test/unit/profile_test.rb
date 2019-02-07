require 'mixlib/log'
require 'fileutils'
require 'minitest/autorun'
require_relative '../../lib/inspec-habitat/profile.rb'

class InspecPlugins::Habitat::ProfileTest < MiniTest::Unit::TestCase
  def setup
    @tmpdir = Dir.mktmpdir

    @output_dir = File.join(@tmpdir, 'output')
    FileUtils.mkdir(@output_dir)

    @fake_hart_file = FileUtils.touch(File.join(@tmpdir, 'fake-hart.hart'))[0]

    @test_profile_path = File.join('test', 'fixture', 'example_profile')

    @hab_profile = InspecPlugins::Habitat::Profile.new(
      @test_profile_path,
      { output_dir: @output_dir }
    )
    Inspec::Log.level(:fatal)
  end

  def after_run
    FileUtils.remove_entry_secure(@tmpdir)
  end

  def test_create_raises_if_output_dir_does_not_exist
    profile = InspecPlugins::Habitat::Profile.new(
      @test_profile_path,
      {
        output_dir: '/not/a/real/path',
        log_level: 'fatal'
      },
    )

    assert_raises { profile.create }
    # TODO: Figure out how to capture and validate `Inspec::Log.error`
  end

  def test_create_exits_if_habitat_is_not_installed
    cmd = MiniTest::Mock.new
    cmd.expect(:error?, true)
    cmd.expect(:run_command, nil)

    Mixlib::ShellOut.stub :new, cmd, 'hab --version' do
      assert_raises { @hab_profile.create }
      # TODO: Figure out how to capture and validate `Inspec::Log.error`
    end

    cmd.verify
  end

  def test_create
    file_count = Dir.glob(File.join(@test_profile_path, '**/*')).count

    @hab_profile.stub :verify_habitat_setup, nil do
      @hab_profile.stub :build_hart, @fake_hart_file do
        @hab_profile.create
      end
    end

    # It should not modify target profile
    new_file_count = Dir.glob(File.join(@test_profile_path, '**/*')).count
    assert_equal new_file_count, file_count

    # It should create 1 Habitat artifact
    output_files = Dir.glob(File.join(@output_dir, '**/*'))
    assert_equal 1, output_files.count
    assert_equal 'fake-hart.hart', File.basename(output_files.first)
  end

  def test_upload_raises_if_no_habitat_auth_token_is_found
    @hab_profile.stub :read_habitat_config, {} do
      assert_raises { @hab_profile.upload(@fake_hart_file) }
      # TODO: Figure out how to capture and validate `Inspec::Log.error`
    end
  end

  def test_upload
    @hab_profile.stub :read_habitat_config, { 'auth_token' => 'FAKETOKEN' } do
      @hab_profile.stub :upload_hart, nil do
        @hab_profile.upload(@fake_hart_file)
        # TODO: Figure out how to capture and validate `Inspec::Log.error`
      end
    end
  end
end
