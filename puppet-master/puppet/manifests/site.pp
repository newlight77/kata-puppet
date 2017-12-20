filebucket { 'main': server => 'puppet.nicolargo.com' }
File { backup => 'main' }

import "node"
