class Extract
  def initialize ninja
    @src = ""
    @add_definitions = ""
    @include_directories = "include_directories( \n"
    ninja.each_line do |l|
        if l.include?('defines') then
            d = l.split(' = ')[1].split ' '
            d.each do |e|
            @add_definitions = @add_definitions + "ADD_DEFINITIONS(#{e}) \n"
            end
        elsif l.include?('include_dirs') then
            inc = l.split(' = ')[1].split ' '
            inc.each do |i|
            @include_directories = @include_directories + i + "\n"
            end
        elsif l.include?('cflags') then
        elsif l.include?('cpflags_cc') then
        elsif l.include?('build') then 
             @src += l.split(' ')[-1] if l.include? 'cxx' or l.include?('gcc')
        end
    end
    @include_directories = @include_directories + '}'
  end
  def gen_cmake 
    puts @add_definitions
    ver = '3.1.4'
    name = 'api'
    cmake_lists = %Q{
cmake_minimum_required(VERSION #{ver})

#project name
project(#{name})

#lib output directory
#set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${PROJECT_SOURCE_DIR}/../libs)
#set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${PROJECT_SOURCE_DIR}/../libs)

#add sub directory
add_subdirectory(audio)
add_subdirectory(audio_codecs)
add_subdirectory(video)
add_subdirectory(video_codecs)
add_subdirectory(transport)
add_subdirectory(libjingle_peerconnection_api)

set_property(TARGET api_audio api_audio_codecs api_video api_video_codecs transport libjingle_peerconnection_api PROPERTY FOLDER api)

#current path
#{@include_directories}

#macro define
#{@add_definitions}
    }
    File.open('CMakeLists.txt', 'w') do |f|
        f.write cmake_lists
    end
  end
  def extract_dep alink
        alink = alink.to_s
        ary_alink = alink.split ' '
        ary_alink.delte_if {|e| e.to_s.include?'stamp'}
        a = Array.new 
        o = Array.new
        deps = Arrary.new 
        ary_alink.each do |e|
            o << e if e.to_s.include? '.o'
            a << e if e.to_s.include? '.a'
        end
        a.each do |e|
            f = File::basename e
            f.gsub('lib','').gsub('.a','.ninja')
            deps << (File::dirname(e)+  '/' + f)
        end
  end
end


