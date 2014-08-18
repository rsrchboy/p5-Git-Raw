package Git::Raw::Repository;

use strict;
use warnings;

use Git::Raw;

=head1 NAME

Git::Raw::Repository - Git repository class

=head1 SYNOPSIS

    use Git::Raw;

    # clone a Git repository
    my $url  = 'git://github.com/ghedo/p5-Git-Raw.git';
    my $repo = Git::Raw::Repository -> clone($url, 'p5-Git-Raw', {
      'callbacks' => {
        'transfer_progress' => sub {
          my ($total_objects, $received_objects, $local_objects, $total_deltas,
            $indexed_deltas, $received_bytes) = @_;

          print "Objects: $received_objects/$total_objects", "\n";
          print "Received: ", int($received_bytes/1024), "KB", "\n";
        }
      }
    });

    # print all the tags of the repository
    foreach my $tag ($repo -> tags) {
      say $tag -> name;
    }

=head1 DESCRIPTION

A L<Git::Raw::Repository> represents a Git repository.

B<WARNING>: The API of this module is unstable and may change without warning
(any change will be appropriately documented in the changelog).

=head1 METHODS

=head2 init( $path, $is_bare )

Initialize a new repository at C<$path>.

=head2 clone( $url, $path, \%opts )

Clone the repository at C<$url> to C<$path>. Valid fields for the C<%opts> hash
are:

=over 4

=item * "bare"

If true (default is false) create a bare repository.

=item * "checkout_branch"

The name of the branch to checkout (default is to use the remote's HEAD).

=item * "disable_checkout"

If true (default is false) files will not be checked out after the clone completes.

=item * "callbacks"

=over 8

=item * "remote_create"

Remote customization callback. If a non-default remote is required, i.e. a remote
with a remote name other than 'origin', this callback should be used. The callback
receives a L<Git::Raw::Repository> object, a string containing the default name
for the remote, typically 'origin', and a string containing the URL of the remote.
This callbacks should return a L<Git::Raw::Remote> object. The returned object and
the the repository object passed to this callback is ephemeral. Do not take any
references to it as it may be freed internally.

=item * "credentials"

The callback to be called any time authentication is required to connect to the
remote repository. The callback receives a string containing the URL of the
remote, and it must return a L<Git::Raw::Cred> object.

=item * "sideband_progress"

Textual progress from the remote. Text send over the progress side-band will be
passed to this function (this is the 'counting objects' output). The callback
receives a string containing progress information.

=item * "transfer_progress"

During the download of new data, this will be regularly called with the current
count of progress done by the indexer. The callback receives the following
integers: C<total_objects>, C<received_objects>, C<local_objects>,
C<total_deltas>, C<indexed_deltas> and C<received_bytes>.

=item * "update_tips"

Each time a reference is updated locally, this function will be called with
information about it. The callback receives a string containing the name of the
reference that was updated, and the two OID's C<"a"> before and C<"b"> after the
update.

=back

=back

=head2 open( $path )

Open the repository at C<$path>.

=head2 discover( $path )

Discover the path to the repository directory given a subdirectory.

=head2 new( )

Create a new repository with neither backends nor config object.

=head2 config( )

Retrieve the default L<Git::Raw::Config> of the repository.

=head2 index( )

Retrieve the default L<Git::Raw::Index> of the repository.

=head2 head( [$new_head, $message] )

Retrieve the L<Git::Raw::Reference> pointed by the HEAD of the repository. If
the L<Git::Raw::Reference> C<$new_head> is passed, the HEAD of the repository
will be changed to point to it. If a C<$message> is provided, it will be
used to create the reflog entry, alternatively, the reflog message will simply
be C<"reset">.

=head2 detach_head( $commitish, [$message] )

Make the repository HEAD point directly to a commit. C<$commitish> should be
peelable to a L<Git::Raw::Commit> object, that is, it should be a
L<Git::Raw::Commit> or L<Git::Raw::Reference> object, or alternatively a commit
id or commit id prefix. If a C<$message> is provided, it will be used to create
the reflog entry, alternatively, the reflog message will simply be C<"reset">.

=head2 lookup( $id )

Retrieve the object corresponding to C<$id>.

=head2 checkout( $object, \%opts )

Updates the files in the index and working tree to match the content of
C<$object>. Valid fields for the C<%opts> hash are:

=over 4

=item * "checkout_strategy"

Hash representing the desired checkout strategy. Valid fields are:

=over 8

=item * "none"

Dry-run checkout strategy. It doesn't make any changes, but checks for
conflicts.

=item * "force"

Take any action to make the working directory match the target (pretty much the
opposite of C<"none">.

=item * "safe"

Make only modifications that will not lose changes (to be used in order to
simulate C<git checkout>.

=item * "safe_create"

Like C<"safe">, but will also cause a file to be checked out if it is missing
from the working directory even if it is not modified between the target and
baseline (to be used in order to simulate C<git checkout-index> and C<git clone>).

=item * "allow_conflicts"

Apply safe updates even if there are conflicts.

=item * "remove_untracked"

Remove untracked files from the working directory.

=item * "remove_ignored"

Remove ignored files from the working directory.

=item * "update_only"

Only update files that already exists (files won't be created not deleted).

=item * "dont_update_index"

Do not write the updated files' info to the index.

=item * "no_refresh"

Do not reload the index and git attrs from disk before operations.

=item * "skip_unmerged"

Skip files with unmerged index entries, instead of treating them as conflicts.

=back

=item * "notify"

Notification flags for the notify callback. A list of the following options:

=over 8

=item * "conflict"

Notifies about conflicting paths.

=item * "dirty"

Notifies about file that don't need an update but no longer matches the baseline.
Core git displays these files when checkout runs, but won't stop the checkout.

=item * "updated"

Notification on any file changed.

=item * "untracked"

Notification about untracked files.

=item * "ignored"

Notifies about ignored files.

=item * "all"

All of the above.

=back

=item * "callbacks"

Hash containing progress and notification callbacks. Valid fields are:

=over 8

=item * "notify"

This callback is called for each file matching one of the C<notify> options
selected. It runs before modifying any files on disk. This callback should
return a non-zero value should the checkout be cancelled.  The callback receives
a string containing the path of the file C<$path> and an array reference
containing the reason C<$why>.

=item * "progress"

The callback to be invoked as a file is checked out. The callback receives a
string containing the path of the file C<$path>, an integer C<$completed_steps>
and an integer C<$total_steps>.

=back

=item * "paths"

An optional array representing the list of files thay should be checked out. If
C<"paths"> is not specified, all files will be checked out (default).

=item * "our_label"

The name of the "our" side of conflicts.

=item * "their_label"

The name of the "their" side of conflicts.

=item * "ancestor_label"

The name of the common ancestor side of conflicts.

=item * "target_directory"

Alternative checkout path to the working directory.

=back

Example:

    $repo -> checkout($repo -> head -> target, {
      'checkout_strategy' => { 'safe'  => 1 },
      'notify'    => [ 'all' ],
      'callbacks' => {
         'notify' => sub {
           my ($path, $why) = @_;

           print "File: $path: ", join(' ', @$why), "\n";
         },
         'progress' => sub {
            my ($path, $completed_steps, $total_steps) = @_;

            print "File: $path", "\n" if defined ($path);
            print "Progress: $completed_steps/$total_steps", "\n";
         }
      },
      'paths' => [ 'myscript.pl' ]
    });

=head2 reset( $target, \%opts )

Reset the current HEAD to the given commit. Valid fields for the C<%opts>
hash are:

=over 4

=item * "type"

Set the type of the reset to be performed. Valid values are: C<"soft"> (the head
will be moved to the commit), C<"mixed"> (trigger a soft reset and replace the
index with the content of the commit tree) or C<"hard"> (trigger a C<"mixed">
reset and the working directory will be replaced with the content of the index).

=item * "paths"

List of entries in the index to be updated from the target commit tree.  This is
particularly useful to implement C<"git reset HEAD -- file file"> behaviour.
Note, if this parameter is specified, a value of C<"mixed"> will be used for
C<"type"> (setting C<"type"> to C<"soft"> or C<"hard"> has no effect).

=back

=head2 status( \%opts, [$file, $file, ...] )

Retrieve the status of files in the index and/or working directory. This functions
returns a hash reference with an entry for each C<$file>, or all files if no file
parameters are provided. Each C<$file> entry has a list of C<"flags">, which may
include: C<"index_new">, C<"index_modified">, C<"index_deleted">, C<"index_renamed">,
C<"worktree_new">, C<"worktree_modified">, C<"worktree_deleted">,
C<"worktree_renamed">, C<"worktree_unreadable"> and C<"ignored">.

If C<$file> has been renamed in either the index or worktree or both, C<$file>
will also have a corresponding entry C<"index"> and/or C<"worktree">, containing
the previous filename C<"old_file">.

Valid fields for the C<%opts> hash are:

=over 4

=item * "flags"

Flags for the status. Valid values include:

=over 8

=item * "include_untracked"

Callbacks should be made on untracked files. These will only be made if the
workdir files are included in the C<$show> option.

=item * "include_ignored"

Callbacks should be made on ignored files. These will only be made if the
ignored files get callbacks.

=item * "include_unmodified"

Include even unmodified files.

=item * "exclude_submodules"

Submodules should be skipped. This only applies if there are no pending
typechanges to the submodule (either from or to another type).

=item * "recurse_untracked_dirs"

All files in untracked directories should be included. Normally if an entire
directory is new, then just the top-level directory is included (with a
trailing slash on the entry name). This flag includes all of the individual
files in the directory instead.

=item * "disable_pathspec_match"

Each C<$file> specified should be treated as a literal path, and not as a
pathspec pattern.

=item * "recurse_ignored_dirs"

The contents of ignored directories should be included in the status. This is
like doing C<git ls-files -o -i --exclude-standard> with core git.

=item * "renames_head_to_index"

Rename detection should be processed between the head and the index.

=item * "renames_index_to_workdir"

Rename detection should be run between the index and the working directory.

=item * "sort_case_sensitively"

Override the native case sensitivity for the file system and forces the output
to be in case-sensitive order.

=item * "sort_case_insensitively"

Override the native case sensitivity for the file system and forces the output
to be in case-insensitive order.

=item * "renames_from_rewrites"

Rename detection should include rewritten files.

=item * "no_refresh"

Bypass the default status behavior of doing a "soft" index reload (i.e.
reloading the index data if the file on disk has been modified outside
C<Git::Raw>).

=item * "update_index"

Refresh the stat cache in the index for files that are unchanged but have out
of date stat information in the index. It will result in less work being done
on subsequent calls to C<status>. This is mutually exclusive with the
C<"no_refresh"> option.

=item * "include_unreadable"

Include unreadable files.

=item * "include_unreadable_as_untracked"

Include unreadable files as untracked files.

=back

=item * "show"

One of the following values (Defaults to C<index_and_worktree>):

=over 8

=item * "index_and_worktree"

=item * "index"

=item * "worktree"

=back

=back

Example:

    my $opts = {
      'flags' => {
        'include_untracked'        => 1,
        'renames_head_to_index'    => 1,
        'renames_index_to_workdir' => 1,
      },
      'show' => 'index_and_worktree'
    };
    my $file_statuses = $repo -> status($opts);
    while (my ($file, $status) = each %$file_statuses) {
      my $flags = $status -> {'flags'};
      print "File: $file: Status: ", join (' ', @$flags), "\n";

      if (grep { $_ eq 'index_renamed' } @$flags) {
        print "Index previous filename: ",
        $status -> {'index'} -> {'old_file'}, "\n";
      }

      if (grep { $_ eq 'worktree_renamed' } @$flags) {
        print "Worktree previous filename: ",
        $status -> {'worktree'} -> {'old_file'}, "\n";
      }
    }

=head2 merge_base( @objects )

Find the merge base between C<@objects>. Each element in C<@objects> should be
peelable to a L<Git::Raw::Commit> object, that is, it should be a
L<Git::Raw::Commit> or L<Git::Raw::Reference> object, or alternatively a commit
id or commit id prefix.

=head2 merge_analysis( $reference )

Analyzes the given C<$reference> and determines the opportunities for merging
them into the HEAD of the repository. This function returns an array reference
with optional members C<"normal">, C<"up_to_date">, C<"fast_forward"> and/or
C<"unborn">.

=over 4

=item * "normal"

A "normal" merge. Both HEAD and the given merge input have diverged from their
common ancestor. The divergent commits must be merged.

=item * "up_to_date"

All given merge inputs are reachable from HEAD, meaning the repository is
up-to-date and no merge needs to be performed.

=item * "fast_forward"

The given merge input is a fast-forward from HEAD and no merge needs to be
performed. Instead, the given merge input may be checked out.

=item * "unborn"

The HEAD of the current repository is "unborn" and does not point to a valid
commit. No merge can be performed, but the caller may wish to simply set
HEAD to the target commit(s).

=back

=head2 merge( $ref, [\%merge_opts, \%checkout_opts])

Merge the given C<$ref> into HEAD. This function returns a hash reference
with members C<"up_to_date">, C<"fast_forward"> and C<"id"> if the merge
was fast-forward.  See C<Git::Raw::Repository-E<gt>checkout()> for valid
C<%checkout_opts> values.  Valid fields for C<%merge_opts> are

=over 4

=item * "flags"

An array of flags for the tree, including:

=over 8

=item * "find_renames"

Detect renames.

=back

=item * "favor"

Specify content automerging behaviour. Valid values are C<"ours">, C<"theirs">,
and C<"union">.

=item * "rename_threshold"

Similarity metric for considering a file renamed (default is 50).

=item * "target_limit"

Maximum similarity sources to examine (overrides the C<"merge.renameLimit">
configuration entry) (default is 200).

=back

Example:

    my $branch = Git::Raw::Branch -> lookup($repo, 'branch', 1);
    my $analysis = $repo -> merge_analysis($branch);
    my $merge_opts = {
      'favor' => 'theirs'
    };
    my $checkout_opts = {
      'checkout_strategy' => {
        'force' => 1
      }
    };
    $repo -> merge($branch1, $merge_opts, $checkout_opts);

=head2 ignore( $rules )

Add an ignore rules to the repository. The format of the rules is the same one
of the C<.gitignore> file (see the C<gitignore(5)> manpage). Example:

    $repo -> ignore("*.o\n");

=head2 path_is_ignored( $path )

Checks the ignore rules to see if they would apply to the given file. This indicates
if the file would be ignored regardless of whether the file is already in the index
or committed to the repository.

=head2 diff( [\%diff_opts] )

Compute the L<Git::Raw::Diff> between the repo's default index and another tree.
Valid fields for the C<%diff_opts> hash are:

=over 4

=item * "tree"

If provided, the diff is computed between C<"tree"> and the repo's default index.
The default is the repo's working directory.

=item * "flags"

Flags for generating the diff. Valid values include:

=over 8

=item * "reverse"

Reverse the sides of the diff.

=item * "include_ignored"

Include ignored files in the diff.

=item * "include_typechange"

Enable the generation of typechange delta records.

=item * "recurse_ignored_dirs"

Even if C<"include_ignored"> is specified, an entire ignored directory
will be marked with only a single entry in the diff. This flag adds all files
under the directory as ignored entries, too.

=item * "include_untracked"

Include untracked files in the diff.

=item * "recurse_untracked_dirs"

Even if C<"include_untracked"> is specified, an entire untracked directory
will be marked with only a single entry in the diff (core git behaviour).
This flag adds all files under untracked directories as untracked entries, too.

=item * "ignore_filemode"

Ignore file mode changes.

=item * "ignore_case"

Use case insensitive filename comparisons.

=item * "ignore_submodules"

Treat all submodules as unmodified.

=item * "ignore_whitespace"

Ignore all whitespace.

=item * "ignore_whitespace_change"

Ignore changes in amount of whitespace.

=item * "ignore_whitespace_eol"

Ignore whitespace at end of line.

=item * "skip_binary_check"

Disable updating of the binary flag in delta records.

=item * "enable_fast_untracked_dirs"

When diff finds an untracked directory, to match the behavior of core git, it
scans the contents for ignored and untracked files. If all contents are ignore,
then the directory is ignored. If any contents are not ignored, then the
directory is untracked.  This is extra work that may not matter in many cases.
This flag turns off that scan and immediately labels an untracked directory
as untracked (changing the behavior to not match core git).

=item * "show_untracked_content"

Include the content of untracked files. This implies C<"include_untracked">.

=item * "show_unmodified"

Include the names of unmodified files.

=item * "patience"

Use the C<"patience diff"> algorithm.

=item * "minimal"

Take extra time to find minimal diff.

=item * "show_binary"

Include the necessary deflate / delta information so that C<git apply> can
apply given diff information to binary files.

=item * "force_text"

Treat all files as text, disabling binary attributes and detection.

=item * "force_binary"

Treat all files as binary, disabling text diffs.

=back

=item * "prefix"

=over 8

=item * "a"

The virtual C<"directory"> to prefix to old file names in hunk headers.
(Default is C<"a">.)

=item * "b"

The virtual C<"directory"> to prefix to new file names in hunk headers.
(Default is C<"b">.)

=back

=item * "context_lines"

The number of unchanged lines that define the boundary of a hunk (and
to display before and after)

=item * "interhunk_lines"

The maximum number of unchanged lines between hunk boundaries before
the hunks will be merged into a one.

=item * "paths"

A list of paths to constrain diff.

=back

=head2 blob( $buffer )

Create a new L<Git::Raw::Blob>. Shortcut for C<Git::Raw::Blob-E<gt>create()>.

=cut

sub blob { return Git::Raw::Blob -> create(@_) }

=head2 branch( $name, $target )

Create a new L<Git::Raw::Branch>. Shortcut for C<Git::Raw::Branch-E<gt>create()>.

=cut

sub branch { return Git::Raw::Branch -> create(@_) }

=head2 branches( [$type] )

Retrieve a list of L<Git::Raw::Branch> objects. Possible values for C<$type>
include C<"local">, C<"remote"> or C<"all">.

=head2 commit( $msg, $author, $committer, \@parents, $tree [, $update_ref ] )

Create a new L<Git::Raw::Commit>. Shortcut for C<Git::Raw::Commit-E<gt>create()>.

=cut

sub commit { return Git::Raw::Commit -> create(@_) }

=head2 tag( $name, $msg, $tagger, $target )

Create a new L<Git::Raw::Tag>. Shortcut for C<Git::Raw::Tag-E<gt>create()>.

=cut

sub tag { return Git::Raw::Tag -> create(@_) }

=head2 tags( )

Retrieve the list of L<Git::Raw::Tag> objects representing the
repository's annotated Git tags. Lightweight tags are not returned.

=cut

sub tags {
	my $self = shift;

	my @tags;

	Git::Raw::Tag -> foreach($self, sub {
		push @tags, shift; 0
	});

	return @tags;
}

=head2 stash( $stasher, $msg )

Save the local modifications to a new stash. Shortcut for C<Git::Raw::Stash-E<gt>save()>.

=cut

sub stash { return Git::Raw::Stash -> save(@_) }

=head2 remotes( )

Retrieve the list of L<Git::Raw::Remote> objects.

=head2 refs( )

Retrieve the list of L<Git::Raw::Reference> objects.

=head2 walker( )

Create a new L<Git::Raw::Walker>. Shortcut for C<Git::Raw::Walker-E<gt>create()>.

=cut

sub walker { return Git::Raw::Walker -> create(@_) }

=head2 path( )

Retrieve the complete path of the repository.

=head2 workdir( [$new_dir] )

Retrieve the working directory of the repository. If C<$new_dir> is passed, the
working directory of the repository will be set to the directory.

=head2 blame( $path )

Retrieve blame information for C<$path>. Returns a L<Git::Raw::Blame> object.

=head2 cherry_pick( $commit, [\%merge_opts, \%checkout_opts, $mainline] )

Cherry-pick the given C<$commit>, producing changes in the index and working
directory. See C<Git::Raw::Repository-E<gt>merge()> for valid C<%merge_opts>
and C<%checkout_opts> values. For merge commits C<$mainline> specifies the
parent.

=head2 revert( $commit, [\%merge_opts, \%checkout_opts, $mainline] )

Revert the given C<$commit>, producing changes in the index and working
directory. See C<Git::Raw::Repository-E<gt>merge()> for valid C<%merge_opts>
and C<%checkout_opts> values. For merge commits C<$mainline> specifies the
parent.

=head2 revparse( $spec )

TO BE COMPLETED

=head2 state( )

Determine the state of the repository. One of the following values is returned:

=over 4

=item * "none"

Normal state

=item * "merge"

Repository is in a merge.

=item * "revert"

Repository is in a revert.

=item * "cherry_pick"

Repository is in a cherry-pick.

=item * "bisect"

Repository is bisecting.

=item * "rebase"

Repository is rebasing.

=item * "rebase_interactive"

Repository is in an interactive rebase.

=item * "rebase_merge"

Repository is in an rebase merge.

=item * "apply_mailbox"

Repository is applying patches.

=item * "mailbox_or_rebase"

Repository is applying patches or rebasing.

=back

=head2 state_cleanup( )

Remove all the metadata associated with an ongoing command like merge, revert,
cherry-pick, etc.

=head2 message( )

Retrieve the content of git's prepared message i.e. C<".git/MERGE_MSG">.

=head2 is_empty( )

Check if the repository is empty.

=head2 is_bare( )

Check if the repository is bare.

=head2 is_shallow( )

Check if the repository is a shallow clone.

=head2 is_head_detached( )

Check if the repository's C<HEAD> is detached, that is, it points directly to
a commit.

=head1 AUTHOR

Alessandro Ghedini <alexbio@cpan.org>

Jacques Germishuys <jacquesg@striata.com>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of Git::Raw::Repository
