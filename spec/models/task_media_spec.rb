require 'rails_helper'

RSpec.describe Task, type: :model do
  def create_test_file(filename, content_type)
    file_path = Rails.root.join('spec', 'fixtures', filename)
    Rack::Test::UploadedFile.new(file_path, content_type)
  end

  describe "media files validations" do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
    let(:task) { create(:task, project: project, user: user) }

    context "with valid media files" do
      it "allows attaching a single image file" do
        image_file = create_test_file('test_image.png', 'image/png')
        task.media_files.attach(image_file)
        task.save

        expect(task).to be_valid
        expect(task.media_files.count).to eq(1)
      end

      it "allows attaching a PDF file" do
        pdf_file = create_test_file('test_document.pdf', 'application/pdf')
        task.media_files.attach(pdf_file)
        task.save

        expect(task).to be_valid
        expect(task.media_files.count).to eq(1)
      end

      it "allows attaching multiple files up to the limit" do
        10.times do |i|
          file = create_test_file('test_image.png', 'image/png')
          task.media_files.attach(file)
        end
        task.save

        expect(task).to be_valid
        expect(task.media_files.count).to eq(10)
      end
    end

    context "with invalid file count" do
      it "rejects more than 10 files" do
        10.times do
          file = create_test_file('test_image.png', 'image/png')
          task.media_files.attach(file)
        end
        task.save

        expect(task).to be_valid

        # Try to attach an 11th file
        extra_file = create_test_file('test_image.png', 'image/png')
        task.media_files.attach(extra_file)
        task.save

        expect(task).not_to be_valid
        expect(task.errors[:media_files]).to include("cannot exceed 10 files")
      end
    end

    context "with invalid file size" do
      it "rejects files larger than 10MB" do
        # Create a file that's too large by mocking the byte_size
        large_file = create_test_file('test_document.pdf', 'application/pdf')
        task.media_files.attach(large_file)

        # Mock the byte_size to be over the limit
        allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).and_return(11.megabytes)

        task.save

        expect(task).not_to be_valid
        expect(task.errors[:media_files].any? { |msg| msg.include?("exceeds the maximum file size") }).to be true
      end
    end

    context "with invalid file types" do
      it "rejects executable files" do
        # Create a file and mock its content_type
        executable_file = create_test_file('test_document.pdf', 'application/pdf')
        task.media_files.attach(executable_file)

        # Mock the content_type to be invalid
        allow_any_instance_of(ActiveStorage::Blob).to receive(:content_type).and_return("application/x-msdownload")

        task.save

        expect(task).not_to be_valid
        expect(task.errors[:media_files].any? { |msg| msg.include?("invalid file type") }).to be true
      end

      it "rejects script files" do
        script_file = create_test_file('test_document.pdf', 'application/pdf')
        task.media_files.attach(script_file)

        # Mock the content_type to be invalid
        allow_any_instance_of(ActiveStorage::Blob).to receive(:content_type).and_return("application/x-sh")

        task.save

        expect(task).not_to be_valid
        expect(task.errors[:media_files].any? { |msg| msg.include?("invalid file type") }).to be true
      end
    end

    context "with allowed file types" do
      it "accepts JPEG images" do
        jpeg_file = create_test_file('test_image.jpg', 'image/jpeg')
        task.media_files.attach(jpeg_file)
        task.save

        expect(task).to be_valid
      end

      it "accepts PNG images" do
        png_file = create_test_file('test_image.png', 'image/png')
        task.media_files.attach(png_file)
        task.save

        expect(task).to be_valid
      end

      it "accepts GIF images" do
        gif_file = create_test_file('test_image.gif', 'image/gif')
        task.media_files.attach(gif_file)
        task.save

        expect(task).to be_valid
      end

      it "accepts SVG images" do
        svg_file = create_test_file('test_image.svg', 'image/svg+xml')
        task.media_files.attach(svg_file)
        task.save

        expect(task).to be_valid
      end

      it "accepts PDF documents" do
        pdf_file = create_test_file('test_document.pdf', 'application/pdf')
        task.media_files.attach(pdf_file)
        task.save

        expect(task).to be_valid
      end
    end
  end

  describe "media files scoping" do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
    let(:task1) { create(:task, project: project, user: user) }
    let(:task2) { create(:task, project: project, user: user) }

    it "scopes media files to the specific task" do
      file1 = create_test_file('test_image.png', 'image/png')
      file2 = create_test_file('test_image.png', 'image/png')

      task1.media_files.attach(file1)
      task2.media_files.attach(file2)
      task1.save
      task2.save

      expect(task1.media_files.count).to eq(1)
      expect(task2.media_files.count).to eq(1)
      expect(task1.media_files.first.id).not_to eq(task2.media_files.first.id)
    end
  end
end
