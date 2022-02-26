# file_structure

[![Gem Version](https://badge.fury.io/rb/file_structure.svg)](https://badge.fury.io/rb/file_structure)
[![Test](https://github.com/durierem/file_structure/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/durierem/file_structure/actions/workflows/test.yml)
[![Lint](https://github.com/durierem/file_structure/actions/workflows/lint.yml/badge.svg?branch=main)](https://github.com/durierem/file_structure/actions/workflows/lint.yml)


Define a file structure with a `Hash` and mount it in a directory on the file system.

## About

This gem was extracted from another project tests for which files structures
containing files, directories and symlinks had to be easily reacreated on the
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
# │  │  └── file2
# │  ├── file3
# │  └── link_to_file2 -> /tmp/mydir/dir1/dir2/file2
# └── file1

fs = FileStructure.new([
  { type: :file, name: 'file1' },
  {
    type: :directory,
    name: 'dir1',
    children: [
      {
        type: :directory,
        name: 'dir2',
        children: [
          { type: :file, name: 'file2', ref: 'ref_file2', content: 'abc' }
        ]
      },
      { type: :file, name: 'file3' },
      { type: :symlink, name: 'link_to_file2', to: 'ref_file2' }
    ]
  }
])

fs.mount('/home/john/mydir') # also creates the directory if it doesn't exist
fs.mounted? # => true
fs.mountpoint # => "/home/john/mydir"
fs.path_for(:dir1, :file3) # => /home/john/mydir/dir1/file3
fs.unmount # deletes all files in /home/john/mydir

# Bonus: can be mounted in a temporary directory
Dir.mktmpdir do |dirname|
  fs.mount(dir)
  # do stuff
  fs.unmount
end

# Bonus: easily serializable structure (who knows what could be done with this :O)
JSON.dump(fs.structure)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
