class Extract
  def initialize ninja
    @cmake_root = File::dirname ninja
    @srcs = ""
    @add_definitions = ""
    @include_directories = "include_directories( \n"
    get_content(ninja).each_line do |l|
        if l == '' then 
            next
        end
        if l.include?('defines = ') then
            d = l.split(' = ')[1].split ' '
            d.each do |e|
            @add_definitions = @add_definitions + "ADD_DEFINITIONS(#{e}) \n"
            end
        elsif l.include?('include_dirs = ') then
            inc = l.split(' = ')[1].split ' '
            inc.each do |i|
            @include_directories = @include_directories + i + "\n"
            end
        elsif l.include?('cflags = ') then
        elsif l.include?('cpflags_cc = ') then
        elsif l.include?('build') then 
             @srcs += l.split(' ')[-1] + "\n" if l.include? ' cxx ' or l.include?(' gcc ')
             extract_dep(l) if l.include? ' alink '
        elsif l.include?('label_name') then
            @name = (l.split(' = ')[1]).gsub "\n", ''
        elsif l.include?('target_out_dir') then
            @out_dir = (l.split(' = ')[1]).gsub "\n",''
        end
    end
    @include_directories = @include_directories + '}'
  end
  def gen_cmake 
    ver = '3.1.4'
    name = @name
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

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Od")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O2")

set(SRC_LIST #{@srcs})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG #{@out_dir})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE #{@out_dir})

ADD_LIBRARY(${PROJECTNAME} STATIC ${SRC_LIST})
    }
    cmake_file = "#{@cmake_root}/CMakeLists.txt"
     $logger.info "#{@name}, cmakelist.txt is #{cmake_file}"
    File.open(cmake_file, 'w') do |f|
        f.write cmake_lists
    end
  end
  def extract_dep alink
        alink = alink.to_s
        ary_alink = alink.split ' '
        ary_alink.delete_if {|e| e.to_s.include?'stamp'}
        a = Array.new 
        o = Array.new
        deps = Array.new 
        ary_alink.each do |e|
            o << e if e.to_s.include? '.o'
            a << e if e.to_s.include? '.a'
        end
        a.each do |e|
            f = File::basename e
            libf = f.gsub('.a','.ninja')

            f.gsub!('lib','').gsub!('.a','.ninja')
            ninja = (File::dirname(e)+  '/' + f)
            libninja = (File::dirname(e)+  '/' + libf)
            if File::exist?(ninja) then 
            deps << ninja
            else
                if File::exist?(libninja) then
                    deps << libninja
                else
                $logger.warn "#{ninja} not exit"
                end
            end
        end
=begin

        $logger.info deps.size
        if deps.size > 0 then
        ex = Extract.new  Dir::pwd + '/' + deps[0].to_s
        ex.gen_cmake
        end
=end
# bug: 当同一目录下有多个ninja的时候，由于CMakeList.txt只能有一个，所以覆盖了。
        deps.each do |e|
            ex = Extract.new  Dir::pwd + '/' + e.to_s
            ex.gen_cmake
        end
  end
private  def get_content p
    rns = ""
    File.open(p, 'r') do |f|
      f.each_line do |l|
          rns += l
      end
    end
    rns
  end
end


