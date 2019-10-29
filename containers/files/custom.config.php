<?php
$CONFIG = array (
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' =>
  array (
    'host' => 'nextcloud-redis',
    'port' => 6379,
  ),
  'mail_from_address' => 'eviloverlord',
  'mail_smtpmode' => 'smtp',
  'mail_sendmailmode' => 'smtp',
  'mail_domain' => 'chambana.net',
  'mail_smtpsecure' => 'tls',
  'mail_smtphost' => 'smtp.chambana.net',
  'mail_smtpport' => '587',
  'mail_smtpauthtype' => 'PLAIN',
  'mail_smtpauth' => 1,
  'mail_smtpname' => 'eviloverlord',
  'mail_smtppassword' => '{{ mail_password }}',
  'overwriteprotocol' => 'https'
);
