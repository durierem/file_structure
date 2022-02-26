# FileStructure

Describe a file structure with a Ruby Hash. Supports files, file content,
directories and symlinks across the structure.

Mount and unmount the desired structured in a directory on the file system.

Useful for creating test environment for programs that manipulate
files but can be used as is for something else entirely.

## Usage

```ruby
# Example creating the following file hierarchy:
# /tmp/mydir
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
fs.mount('/tmp/mydir') # also creates the /tmp/mydir directory if it doesn't exist
fs.mounted? # => true
fs.mountpoint # => "/tmp/mydir"
fs.unmount # deletes all files in /tmp/mydir
JSON.dump(fs.structure) # (bonus) easily serializable :D
```

## Next features?

Add a nice DSL for initilazing `FileStructure`s

```ruby
FileStructure.new do
  file 'file1', content: 'abc' # ref defaults to file name
  dir 'foo' do
    file 'file2', content: '123'
    symlink 'iamfile1', to: 'file1'
  end
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
