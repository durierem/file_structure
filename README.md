# file_structure

[![Gem Version](https://badge.fury.io/rb/file_structure.svg)](https://badge.fury.io/rb/file_structure)
[![Test](https://github.com/durierem/file_structure/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/durierem/file_structure/actions/workflows/test.yml)
[![Lint](https://github.com/durierem/file_structure/actions/workflows/lint.yml/badge.svg?branch=main)](https://github.com/durierem/file_structure/actions/workflows/lint.yml)


Describe a file hierarchy and mount it in a directory on the file system.

## About

This gem was extracted from another project tests for which structures
containing files, directories and symlinks had to be easily recreated on the
fly.

Though it *is* useful in the context of testing, `file_structure` does not make
assumptions about what it is being used for and deliberately does not handle
things such as temporary file structures or mock file structures.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'file_structure'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install file_structure


## Usage

Visit the [API documentation](https://www.rubydoc.info/github/durierem/file_structure/)
for more details.

```ruby
# Example creating the following file hierarchy:
# /home/john/mydir
# ├── dir1
# │  ├── dir2
# │  │  └── file2 (containing "Hello, World!")
# │  ├── file3
# │  └── link_to_file2 -> /home/john/mydir/dir1/dir2/file2
# └── file1

# Use the DSL to easily describe the structure
fs = FileStructure.build do
  file 'file1'
  directory 'dir1' do
    directory 'dir2' do
      file 'file2', content: 'Hello, World!'
    end
    file 'file3'
    symlink 'link_to_file2', to: 'file2'
  end
end

# Operations on file structures
fs.mount('/home/john/mydir')    # also creates the directory if it doesn't exist
fs.mounted?                     # => true
fs.mountpoint                   # => "/home/john/mydir"
fs.path_for('dir1/file3')       # => "/home/john/mydir/dir1/file3"
fs.unmount                      # deletes all files in /home/john/mydir
```

## Bonus

```ruby
# Can be mounted in a temporary directory
Dir.mktmpdir do |dirname|
  fs.mount(dirname)
  # do stuff
  fs.unmount
end

# Easily serializable structure (who knows what could be done with this :O)
JSON.dump(fs.structure)
```

## Changelog

See [CHANGELOG.md](https://github.com/durierem/file_structure/blob/main/CHANGELOG.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
