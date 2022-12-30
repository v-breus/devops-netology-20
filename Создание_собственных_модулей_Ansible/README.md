# Домашнее задание к занятию "6.Создание собственных модулей"

## Подготовка к выполнению
1. Создайте пустой публичных репозиторий в любом своём проекте: `my_own_collection`
2. Скачайте репозиторий ansible: `git clone https://github.com/ansible/ansible.git` по любому удобному вам пути
3. Зайдите в директорию ansible: `cd ansible`
4. Создайте виртуальное окружение: `python3 -m venv venv`
5. Активируйте виртуальное окружение: `. venv/bin/activate`. Дальнейшие действия производятся только в виртуальном окружении
6. Установите зависимости `pip install -r requirements.txt`
7. Запустить настройку окружения `. hacking/env-setup`
8. Если все шаги прошли успешно - выйти из виртуального окружения `deactivate`
9. Ваше окружение настроено, для того чтобы запустить его, нужно находиться в директории `ansible` и выполнить конструкцию `. venv/bin/activate && . hacking/env-setup`

<p><img src="img\pic1.png">


## Основная часть

Наша цель - написать собственный module, который мы можем использовать в своей role, через playbook. Всё это должно быть собрано в виде collection и отправлено в наш репозиторий.

1. В виртуальном окружении создать новый `my_own_module.py` файл
2. Наполнить его:

<details>
<summary>Содержимое</summary>

```
#!/usr/bin/python

# Copyright: (c) 2018, Terry Jones <terry.jones@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_test

short_description: This is my test module

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: This is my longer description explaining my test module.

options:
    name:
        description: This is the message to send to the test module.
        required: true
        type: str
    new:
        description:
            - Control to demo if the result of this module is changed or not.
            - Parameter description can be a list as well.
        required: false
        type: bool
# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
extends_documentation_fragment:
    - my_namespace.my_collection.my_doc_fragment_name

author:
    - Your Name (@yourGitHubHandle)
'''

EXAMPLES = r'''
# Pass in a message
- name: Test with a message
  my_namespace.my_collection.my_test:
    name: hello world

# pass in a message and have changed true
- name: Test with a message and changed output
  my_namespace.my_collection.my_test:
    name: hello world
    new: true

# fail the module
- name: Test failure of the module
  my_namespace.my_collection.my_test:
    name: fail me
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
original_message:
    description: The original name param that was passed in.
    type: str
    returned: always
    sample: 'hello world'
message:
    description: The output message that the test module generates.
    type: str
    returned: always
    sample: 'goodbye'
'''

from os import stat
from ansible.module_utils.basic import AnsibleModule

def file_exist(path):
    '''Check that file already exist'''
    try:
        stat(path)
        return False
    except Exception:
        return True

def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=False, default='absolute content')
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        result['changed'] = file_exist(module.params['path'])
        module.exit_json(**result)

    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)
    if file_exist(module.params['path']):
      with open(module.params['path'], 'w') as new_file:
          new_file.write(module.params["content"])
      result['changed'] = True
      result['original_message'] = 'File {path} succesfully created'.format(path = module.params['path'])
      result['message'] = 'file created'
    else:
      result['original_message'] = 'File {path} already exist'.format(path = module.params['path'])
      result['message'] = 'File already exist'  

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
```
</details>

3. Заполните файл в соответствии с требованиями ansible так, чтобы он выполнял основную задачу: module должен создавать текстовый файл на удалённом хосте по пути, определённом в параметре `path`, с содержимым, определённым в параметре `content`.

[module](https://github.com/v-breus/ansible-modules/blob/main/my_own_module.py)

4. Проверьте module на исполняемость локально.

<p><img src="img\pic2.png">

5. Напишите single task playbook и используйте module в нём.

Playbook
```
---
- name: Check module
  hosts: localhost
  tasks:
    - name: Test
      my_own_module:
        path: "/tmp/test.txt"
        content: "My homework"
```

Запуск

<p><img src="img\pic3.png">


6. Проверьте через playbook на идемпотентность.

<p><img src="img\pic4.png">

7. Выйдите из виртуального окружения

`deactivate`

8. Инициализируйте новую collection: `ansible-galaxy collection init my_own_elk`

<p><img src="img\pic5.png">

9. В данную collection перенесите свой module в соответствующую директорию.

<p><img src="img\pic6.png">

10. Single task playbook преобразуйте в single task role и перенесите в collection. У role должны быть default всех параметров module

<p><img src="img\pic7.png">

11. Создайте playbook для использования этой role.

<p><img src="img\pic8.png">

12. Заполните всю документацию по collection, выложите в свой репозиторий, поставьте тег `1.0.0` на этот коммит.
13. Создайте .tar.gz этой collection: `ansible-galaxy collection build` в корневой директории collection.

<p><img src="img\pic9.png">

14. Создайте ещё одну директорию любого наименования, перенесите туда single task playbook и архив c collection.
15. Установите collection из локального архива: `ansible-galaxy collection install <archivename>.tar.gz`

<p><img src="img\pic10.png">

16. Запустите playbook, убедитесь, что он работает.

<p><img src="img\pic11.png">

17. В ответ необходимо прислать ссылку на репозиторий с collection

[ссылка](https://github.com/v-breus/devops-netology-20/tree/main/Создание_собственных_модулей_Ansible/galaxy_collection/collections/ansible_collections/test_namespace/test_collection)
