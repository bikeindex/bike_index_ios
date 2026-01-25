# ABANDONING THIS APPROACH
# Xcode proj has not been updated for Xcode 16+

require 'xcodeproj'

project_path = './BikeIndex.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
  puts target.name
end

puts project.frameworks_group.children.count

project.frameworks_group.children.each do |framework|
	puts framework.name
end

puts project.root_object
puts project.root_object.project_references
puts project.root_object.package_references

project.root_object.package_references.each do |package|
	puts "Package: #{package.display_name}"
end

snapshotPreviewsPackage = project.root_object.package_references.select { |n| n.display_name === "https://github.com/EmergeTools/SnapshotPreviews" }
puts snapshotPreviewsPackage.first
puts snapshotPreviewsPackage.first.class


project.root_object.package_references.delete(snapshotPreviewsPackage.first)
project.save

# TODO: BikeIndex remove dependency SnapshotPreferences
# TODO: BikeIndex remove dependency PreviewGallery
# TODO: UnitTests remove dependency SnapshottingTests
