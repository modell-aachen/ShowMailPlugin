# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

=pod

---+ package Foswiki::Plugins::ShowMailPlugin

When developing a plugin it is important to remember that
Foswiki is tolerant of plugins that do not compile. In this case,
the failure will be silent but the plugin will not be available.
See %SYSTEMWEB%.InstalledPlugins for error messages.

=cut


package Foswiki::Plugins::ShowMailPlugin;

# Always use strict to enforce variable scoping
use strict;
use warnings;

use Foswiki::Func    ();    # The plugins API
use Foswiki::Plugins ();    # For the API version

our $VERSION = '$Rev: 11239 $';

our $RELEASE = "0.0";

# Short description of this plugin
# One line description, is shown in the %SYSTEMWEB%.TextFormattingRules topic:
our $SHORTDESCRIPTION = 'Allows a restricted number of persons to view the email adresses of users.';

our $NO_PREFS_IN_TOPIC = 1;

=begin TML

---++ initPlugin($topic, $web, $user) -> $boolean
   * =$topic= - the name of the topic in the current CGI query
   * =$web= - the name of the web in the current CGI query
   * =$user= - the login name of the user
   * =$installWeb= - the name of the web the plugin topic is in
     (usually the same as =$Foswiki::cfg{SystemWebName}=)

=cut

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if ( $Foswiki::Plugins::VERSION < 2.0 ) {
        Foswiki::Func::writeWarning( 'Version mismatch between ',
            __PACKAGE__, ' and Plugins.pm' );
        return 0;
    }

    Foswiki::Func::registerTagHandler( 'SHOWMAIL', \&_SHOWMAIL );

    Foswiki::Func::registerTagHandler( 'SHOWALLUSERS', \&_SHOWALLUSERS );

    return 1;
}

# see if User was allowed to view this plugin in Configure
sub _isAllowed {
    return 1 if Foswiki::Func::isAnAdmin();

    my ($usersweb, $crap) = Foswiki::Func::normalizeWebTopicName('%USERSWEB%', '');

    my $currentUser = Foswiki::Func::getWikiUserName();
    $currentUser =~ s/^$usersweb\.//;

    # check each item from configure
    my @allowed = split(/\s*,\s*/, $Foswiki::cfg{Extensions}{ShowMailPlugin}{users} || '');
    foreach my $entry (@allowed) {
        # is the user in the list?
        if( $currentUser eq $entry ) {
            return 1;
        }
        # is the user in a group in the list?
        if( Foswiki::Func::isGroup($entry) ) {
            if( Foswiki::Func::isGroupMember($entry, $currentUser) ) {
                return 1;
            }
        }
    }

    return 0;
}


# The function used to handle the %EXAMPLETAG{...}% macro
# You would have one of these for each macro you want to process.
sub _SHOWMAIL {
    my($session, $params, $topic, $web, $topicObject) = @_;
    # $session  - a reference to the Foswiki session object
    #             (you probably won't need it, but documented in Foswiki.pm)
    # $params=  - a reference to a Foswiki::Attrs object containing 
    #             parameters.
    #             This can be used as a simple hash that maps parameter names
    #             to values, with _DEFAULT being the name for the default
    #             (unnamed) parameter.
    # $topic    - name of the topic in the query
    # $web      - name of the web in the query
    # $topicObject - a reference to a Foswiki::Meta object containing the
    #             topic the macro is being rendered in (new for foswiki 1.1.x)
    # Return: the result of processing the macro. This will replace the
    # macro call in the final text.

    # see if User is allowed to view this plugin
    return "Zugriff auf Emails verweigert." unless _isAllowed();

    my $user = $params->{_DEFAULT};
    return unless $user;

    my $adress = join(", ", Foswiki::Func::wikinameToEmails( $user ));

    return $adress;

    # For example, %EXAMPLETAG{'hamburger' sideorder="onions"}%
    # $params->{_DEFAULT} will be 'hamburger'
    # $params->{sideorder} will be 'onions'
}

sub _SHOWALLUSERS {
    my($session, $params, $topic, $web, $topicObject) = @_;

    # see if User is allowed to view this plugin
    return "Zugriff auf Emails verweigert." unless _isAllowed();

    my $list = "| *<nop>WikiName* | *<nop>UserName* | *<nop>EMail* |\n";

    my $iterator = Foswiki::Func::eachUser();
    while ($iterator->hasNext()) {
        my $user = $iterator->next();
        my $adress = join(", ", Foswiki::Func::wikinameToEmails( $user ));
        my $login = Foswiki::Func::wikiToUserName( $user );

        $list .= "| $user | $login | $adress |\n";
    }

    return $list;
}
        

1;

__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Author: %$AUTHOR%

Copyright (C) 2008-2011 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.