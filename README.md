## emacsclient.desktop

emacsclient.desktop位于~/.local/share/applications, 在terminal中打开emacsclient, 参考:
[How can I add 'emacs' to one of the 'Show other application' in file explorer](https://askubuntu.com/questions/283285/how-can-i-add-emacs-to-one-of-the-show-other-application-in-file-explorer)


## 远程连接jupyter notebook

将jupyter_notebook_config.py拷贝到~/.jupyter中:

``` shell
mkdir -p ~/.jupyter && cp ./jupyter_notebook_config.py ~/.jupyter
```

设置登录密码: `jupyter notebook password`, 并将值放入c.NotebookApp.password字段

默认端口为8889, 也可以修改, 字段为: c.NotebookApp.port
