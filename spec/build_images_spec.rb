require 'spec_helper'
require 'rspec/bash'

RSpec.describe "build_images.sh" do
  include Rspec::Bash

  let(:subject) { create_stubbed_env }
  let!(:docker) { subject.stub_command("docker")}

  before(:all) do
    @testpath = Pathname.new File.join(TEST_BASE, "build_images")
    @testpath.mkpath unless File.exist?(@testpath)
    @dirpath = Pathname.new File.join(@testpath, "dir")
    @dirpath.mkpath unless File.exist?(@dirpath)
  end

  after(:all) do
    Pathname.new(@testpath).exist? && Pathname.new(@testpath).rmtree
  end

  describe "Required arguments" do
    context "with all required arguments" do
      before do
        @stdout, @stderr, @status = subject.execute("build_images.sh -i image -d #{@dirpath}")
      end

      it "exists without error" do
        expect(@status.exitstatus).to eq 0
      end
    end

    context "with no arguments" do
      before do
        @stdout, @stderr, @status = subject.execute("build_images.sh")
      end

      it "exists with error" do
        expect(@status.exitstatus).to eq 1
      end

      it "prints the help" do
        expect(@stdout).to include "Usage"
      end
    end

    context "without -i image argument" do
      before do
        @stdout, @stderr, @status = subject.execute("build_images.sh -d #{@dirpath}")
      end

      it "exists with error" do
        expect(@status.exitstatus).to eq 1
      end

      it "notifies about the missing argument" do
        expect(@stdout).to include "Docker image is missing"
      end
    end

    context "without -d dir argument" do
      before do
        @stdout, @stderr, @status = subject.execute("build_images.sh -i image")
      end

      it "exists with error" do
        expect(@status.exitstatus).to eq 1
      end

      it "notifies about the missing argument" do
        expect(@stdout).to include "Directory for build context is missing"
      end
    end

    context "without a valid dir" do
      before do
        @stdout, @stderr, @status = subject.execute("build_images.sh -i image -d nonexistantdir")
      end

      it "exists with error" do
        expect(@status.exitstatus).to eq 1
      end

      it "notifies the directory cannot be found" do
        expect(@stdout).to include "Cannot find directory \"nonexistantdir\" for build context"
      end
    end
  end

  describe "with correct image and dir" do
    context "and no other arguments" do
      before do
        @stdout, @stderr, @status = subject.execute("build_images.sh -i image -d #{@dirpath}")
      end

      it "exists without error" do
        expect(@status.exitstatus).to eq 0
      end

      it "should build the docker image" do
        expect(docker).to be_called_with_arguments("build", "-t", "image:build", @dirpath.to_s).times(1)
      end

      it "should tag the docker image with the default tag" do
        expect(@stdout).to include "Tagging and pushing image with tag \"latest\""
        expect(docker).to be_called_with_arguments("tag", "image:build", "image:latest")
      end

      it "should push the docker image with the default tag" do
        expect(docker).to be_called_with_arguments("push", "image:latest")
      end
    end

    context "and a specific Dockerfile" do
      before do
        @file = 'another-dockerfile'
        @filepath = Pathname.new File.join(@dirpath, @file)
        @filepath.mkpath unless File.exist?(@filepath)
        @stdout, @stderr, @status = subject.execute("build_images.sh -i image -d #{@dirpath} -f #{@file}")
      end

      it "exists without error" do
        expect(@status.exitstatus).to eq 0
      end

      it "should build the docker image" do
        expect(docker).to be_called_with_arguments("build", "-t", "image:build", "-f", "#{@dirpath.to_s}/#{@file}", @dirpath.to_s).times(1)
      end
    end

    context "and a specific Dockerfile that's missing" do
      before do
        @file = 'another-dockerfile'
        @stdout, @stderr, @status = subject.execute("build_images.sh -i image -d #{@dirpath} -f #{@file}")
      end

      it "exists with error" do
        expect(@status.exitstatus).to eq 1
      end

      it "notifies about the missing file" do
        expect(@stdout).to include "Dockerfile '#{@dirpath.to_s}/#{@file}' is missing"
      end
    end

    context "and 1 tag" do
      before do
        @tag = 'tag1'
        @stdout, @stderr, @status = subject.execute("build_images.sh -i image -d #{@dirpath} -t #{@tag}")
      end

      it "exists without error" do
        expect(@status.exitstatus).to eq 0
      end

      it "should build the docker image" do
        expect(docker).to be_called_with_arguments("build", "-t", "image:build", @dirpath.to_s).times(1)
      end

      it "should tag the docker image with the provided tag" do
        expect(@stdout).to include "Tagging and pushing image with tag \"#{@tag}\""
        expect(docker).to be_called_with_arguments("tag", "image:build", "image:#{@tag}")
      end

      it "should push the docker image with the provided tag" do
        expect(docker).to be_called_with_arguments("push", "image:#{@tag}")
      end
    end

    context "and more than 1 tag" do
      before do
        @tags = ['tag1', 'tag2', 'tag3']
        tags = @tags.map{|tag| " -t #{tag}"}.join
        @stdout, @stderr, @status = subject.execute("build_images.sh -i image -d #{@dirpath} #{tags}")
      end

      it "exists without error" do
        expect(@status.exitstatus).to eq 0
      end

      it "should build the docker image" do
        expect(docker).to be_called_with_arguments("build", "-t", "image:build", @dirpath.to_s).times(1)
      end

      it "should tag the docker image with the provided tags" do
        @tags.each do |tag|
          expect(@stdout).to include "Tagging and pushing image with tag \"#{tag}\""
          expect(docker).to be_called_with_arguments("tag", "image:build", "image:#{tag}")
        end
      end

      it "should push the docker image with the provided tags" do
        @tags.each do |tag|
          expect(docker).to be_called_with_arguments("push", "image:#{tag}")
        end
      end
    end

    context "and semantic version" do
      before do
        @tag = 'tag1'
        @version = '1.2.3'
        @stdout, @stderr, @status = subject.execute("build_images.sh -i image -d #{@dirpath} -t #{@tag} -s #{@version}")
      end

      it "exists without error" do
        expect(@status.exitstatus).to eq 0
      end

      it "should build the docker image" do
        expect(docker).to be_called_with_arguments("build", "-t", "image:build", @dirpath.to_s).times(1)
      end

      it "should tag the docker image with the provided tag" do
        expect(@stdout).to include "Tagging and pushing image with tag \"#{@tag}\""
        expect(docker).to be_called_with_arguments("tag", "image:build", "image:#{@tag}")
      end

      it "should push the docker image with the provided tag" do
        expect(docker).to be_called_with_arguments("push", "image:#{@tag}")
      end

      it "should tag the docker image with the full version" do
        expect(@stdout).to include "Adding tags for semantic version \"#{@version}\""
        expect(@stdout).to include "Tagging and pushing image with tag \"#{@version}\""
        expect(docker).to be_called_with_arguments("tag", "image:build", "image:#{@version}")
      end

      it "should push the docker image with the full version" do
        expect(docker).to be_called_with_arguments("push", "image:#{@version}")
      end

      it "should tag the docker image with the minor version" do
        version = @version.split('.', 2).join('.')
        expect(@stdout).to include "Tagging and pushing image with tag \"#{version}\""
        expect(docker).to be_called_with_arguments("tag", "image:build", "image:#{version}")
      end

      it "should push the docker image with the minor version" do
        version = @version.split('.', 2).join('.')
        expect(docker).to be_called_with_arguments("push", "image:#{version}")
      end

      it "should tag the docker image with the major version" do
        version = @version.split('.', 1).join('.')
        expect(@stdout).to include "Tagging and pushing image with tag \"#{version}\""
        expect(docker).to be_called_with_arguments("tag", "image:build", "image:#{version}")
      end

      it "should push the docker image with the major version" do
        version = @version.split('.', 1).join('.')
        expect(docker).to be_called_with_arguments("push", "image:#{version}")
      end
    end

    context "and 1 label" do
      before do
        @label = 'label1=val1'
        @stdout, @stderr, @status = subject.execute("build_images.sh -i image -d #{@dirpath} -l #{@label}")
      end

      it "exists without error" do
        expect(@status.exitstatus).to eq 0
      end

      it "should build the docker image with the provided label" do
        expect(docker).to be_called_with_arguments("build", "--label", @label, "-t", "image:build", @dirpath.to_s).times(1)
      end
    end

    context "and more than 1 label" do
      before do
        @labels = ['label1=val1', 'label2=val2', 'label3=val3']
        labels = @labels.map{|label| " -l #{label}"}.join
        @stdout, @stderr, @status = subject.execute("build_images.sh -i image -d #{@dirpath} #{labels}")
      end

      it "exists without error" do
        expect(@status.exitstatus).to eq 0
      end

      it "should build the docker image with the provided labels" do
        labels = @labels.map{|label| ["--label"] << label}
        expect(docker).to be_called_with_arguments("build", *labels.flatten, "-t", "image:build", @dirpath.to_s).times(1)
      end
    end
  end
end
