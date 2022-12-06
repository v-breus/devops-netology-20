Install Lighthouse
=========

Simple role for install Lighthouse (https://github.com/VKCOM/lighthouse) on EL system.

Role Variables
--------------

| Variable        | Type   | Default                     | Description            |
|-----------------|--------|-----------------------------|------------------------|
| lighthouse_dest | string | /usr/share/nginx/lighthouse | files storage location |


Example Playbook
----------------

    - hosts: servers
      roles:
         - lighthouse-role

License
-------

MIT
