Install Vector
=========

Role for install vector (https://vector.dev/) on Centos 7 system.

Role Variables
--------------

| Variable       | Type   | Default | Description    |
|----------------|--------|---------|----------------|
| vector_version | string | 0.9.2   | Vector version |


Example Playbook
----------------


    - hosts: servers
      roles:
         - vector-role

License
-------

MIT
