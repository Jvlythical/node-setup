require 'zfs'
require 'open3'
require 'fileutils'

def migrate(path, dataset)
	fs = ZFS(dataset)
	return if fs.exist?
	
	puts "Creating dataset: %s" % dataset
	# Move folder into tmp folder
	FileUtils.mv path, '/tmp'
		
	# Create the dataset
	fs.create 

	# Move files back 
	puts "Moving files back..."
	basename = File.basename(path)
	vol = File.join('/tmp', basename)
	stdout, stderr, status = Open3.capture3("mv %s %s" % [File.join(vol, '*'), path])
	puts stderr if status.exitstatus != 0
	stdout, stderr, status = Open3.capture3("mv %s %s" % [File.join(vol, '.*'), path])
	puts stderr if status.exitstatus != 0
end

pool = 'kodethon/production'
buckets = Dir.glob('drives/*')
buckets.each do |bucket|
	# Create bucket if it doesn't exist
	fs = ZFS(File.join(pool, bucket))
	fs.create if not fs.exist?
	
	vols = Dir.glob(File.join(bucket, '*'))
	vols.each do |vol|
		migrate(vol, File.join(pool, vol))
	end
end

