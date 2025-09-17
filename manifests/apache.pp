# @summary
#   Configures Apache HTTP Server with customizable MPM modules, HTTP/2 support, and logging.
#
# @description
#   This class manages Apache HTTP Server configuration with support for multiple MPM (Multi-Processing Module)
#   configurations, HTTP/2 protocol support, custom logging formats, and performance monitoring.
#
#   The class automatically configures:
#   - Apache service with custom MPM modules (prefork, worker, event, itk, peruser)
#   - HTTP/2 protocol support (incompatible with prefork MPM)
#   - Custom log formats for JSON logging
#   - WebP MIME type support
#   - Performance metrics collection (optional)
#   - Essential Apache modules (deflate, dir, unique_id)
#
# @param mpm_module
#   The Multi-Processing Module to use for Apache. Each MPM handles client requests differently:
#   - prefork: Single-threaded, process-based (default, most compatible)
#   - worker: Multi-threaded, multi-process hybrid
#   - event: Enhanced worker with better keep-alive handling
#   - itk: Per-virtual-host user/group isolation
#   - peruser: Per-virtual-host process isolation
#
# @param mpm_module_config
#   Hash of configuration parameters for the selected MPM module.
#   Common parameters include:
#   - startservers: Initial number of server processes/threads
#   - maxrequestworkers: Maximum number of simultaneous connections
#   - threadsperchild: Number of threads per child process (worker/event only)
#
# @param http2
#   Enable HTTP/2 protocol support. When enabled, Apache will accept both HTTP/2 and HTTP/1.1 connections.
#   Note: HTTP/2 is incompatible with prefork MPM and will cause a compilation error.
#
# @param limitreqfieldsize
#   Maximum size limit for HTTP request header fields in bytes.
#   Increase this value if clients send large headers (cookies, tokens, etc.).
#
# @param metrics
#   Enable Apache performance metrics collection and monitoring.
#   When enabled, includes profiles::apache::metrics class for monitoring setup.
#
# @param service_status
#   Desired state of the Apache service.
#   - 'running': Service will be started and enabled at boot
#   - 'stopped': Service will be stopped and disabled at boot
#
# @example Basic usage with default prefork MPM
#   include profiles::apache
#
# @example Worker MPM with custom configuration
#   class { 'profiles::apache':
#     mpm_module        => 'worker',
#     mpm_module_config => {
#       'startservers'      => 4,
#       'maxrequestworkers' => 256,
#       'threadsperchild'   => 25,
#     },
#   }
#
# @example Event MPM with HTTP/2 support
#   class { 'profiles::apache':
#     mpm_module => 'event',
#     http2      => true,
#   }
#
# @example Production configuration with metrics disabled
#   class { 'profiles::apache':
#     mpm_module         => 'worker',
#     limitreqfieldsize  => 16380,
#     metrics           => false,
#     service_status    => 'running',
#   }
#
# @author Publiq Infrastructure Team
# @since 1.0.0
#
class profiles::apache (
  Enum['event', 'itk', 'peruser', 'prefork', 'worker']  $mpm_module        = 'prefork',
  Hash                                                  $mpm_module_config = {},
  Boolean                                               $http2             = false,
  Integer                                               $limitreqfieldsize = 8190,
  Boolean                                               $metrics           = true,
  Enum['running', 'stopped']                            $service_status    = 'running',
) inherits ::profiles {

  if ($mpm_module == 'prefork' and $http2) {
    fail('The HTTP/2 protocol is not supported with MPM module prefork')
  }

  include profiles::apache::defaults
  include profiles::apache::logformats

  realize Group['www-data']
  realize User['www-data']

  class { '::apache':
    default_mods          => false,
    mpm_module            => false,
    manage_group          => false,
    manage_user           => false,
    default_vhost         => true,
    protocols             => $http2 ? {
                               true  => ['h2c', 'http/1.1'],
                               false => ['http/1.1']
                             },
    protocols_honor_order => true,
    limitreqfieldsize     => $limitreqfieldsize,
    service_manage        => true,
    service_ensure        => $service_status,
    service_enable        => $service_status ? {
                               'running' => true,
                               'stopped' => false
                             },
    log_formats           => $profiles::apache::logformats::all,
    require               => [Group['www-data'], User['www-data']]
  }

  if $http2 {
    include apache::mod::http2
  }

  class { "apache::mod::${mpm_module}":
    * => $mpm_module_config
  }

  if $metrics {
    include profiles::apache::metrics
  }

  include profiles::apache::logging

  class { "apache::mod::mime":
    mime_types_additional => {
      'AddType' => { 'image/webp' => '.webp' }
    }
  }

  apache::mod { 'unique_id': }
  include apache::mod::deflate
  include apache::mod::dir
}
