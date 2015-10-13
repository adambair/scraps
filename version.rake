#-----------VERSION RAKE GOODNESS--------------

# The version number is available in the application as APP_VERSION
# It's displayed in the footer in all envs except production

desc "Show the application's version number"
task :version do
  version = read_yaml
  puts "Version #{display(version)}"
end

namespace :version do
  namespace :bump do
    %w(major minor patch).each do |type|
      desc "Bump #{type} version number"
      task type.to_sym do
        version = read_yaml
        version = bump(type.to_sym, version)
        write_yaml(version)
        puts "Bumped version to #{display(version)}"
      end
    end
  end

  desc "Set a specific version number - ex: set_to[1.5.1]"
  task :set_to, :version do |t, args|
    extracted = args[:version].split('.')
    version = {
      :major => extracted[0].to_i,
      :minor => extracted[1].to_i,
      :patch => extracted[2].to_i
    }
    write_yaml(version)
    puts "Set version to #{display(version)}"
  end

  desc "Reset version to 0.0.0"
  task :reset do
    version = {
      :major => 0,
      :minor => 0,
      :patch => 0
    }
    write_yaml(version)
  end

  def display(version)
    [version[:major], version[:minor], version[:patch]].join('.')
  end

  def bump(type, version)
    case type
    when :major
      {
        :major => version[:major] + 1,
        :minor => 0,
        :patch => 0
      }
    when :minor
      {
        :major => version[:major],
        :minor => version[:minor] + 1,
        :patch => 0
      }
    when :patch
      {
        :major => version[:major],
        :minor => version[:minor],
        :patch => version[:patch] + 1
      }
    else
      raise "Incorrect version component '#{type}' (:major, :minor, :patch) expected"
    end
  end
  
  def read_yaml(file='VERSION.yml')
    YAML.load_file(File.join(RAILS_ROOT, file))
  end

  def write_yaml(data, file='VERSION.yml')
    yamlized_data = data.to_yaml
    open(file, 'w') {|f| f << yamlized_data}
    yamlized_data
  end
end
