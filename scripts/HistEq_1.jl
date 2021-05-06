# Performs histogram equalization on a batch of images. 
# Requires a target image (master histogram), source folder (to correct) and destination folder

using DrWatson
@quickactivate "HistEq"

using Images

# construct the argument parser and parse the arguments
function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--target", "-t"
            help = "path to target image with desired histogram"
            arg_type = String
            required = true
        "--source", "-s"
            help = "path to source folder of images to adjust"
            arg_type = String
            required = true
        "--adjusted", "-a"
            help = "path to folder where to put adjusted images"
            arg_type = String
            required = true
    end
    return parse_args(s)
end

"""
    batch_histeq(target_path, source_dir, adjusted_dir)

Adjusts images from the source folder to match the histogram of the target image,
based on the Images.jl adjust_histogram function (Burger & Burge, 2016).
Then writes images to the adjusted folder. Uses all threads available at startup.
"""
function batch_histeq(target_path::String, source_dir::String, adjusted_dir::String)
    # test/running: switch commenting between next line and the one after
    args = parse_commandline()
    # args = Dict([("target", raw"C:\Projects\20210420_Wimmertingen\101MEDIA\DJI_0078.JPG"), ("source", raw"C:\Projects\20210420_Wimmertingen\ANAFI"), ("adjusted", raw"C:\Projects\20210420_Wimmertingen\equalized")])
        
    const img_target = load(args["target"])
    for (root, dirs, files) in walkdir(args["source"])
        Threads.@threads for file in files
            img_source = load(joinpath(root,file))
            img_adjusted = adjust_histogram(img_source, Matching(targetimg = img_target))
            save(joinpath(args["adjusted"],file),img_adjusted)
        end
    end
end

batch_histeq(target_path, source_dir, adjusted_dir)

println("script completed")