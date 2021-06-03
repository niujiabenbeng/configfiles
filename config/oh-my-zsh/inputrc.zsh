#! /bin/zsh

### zsh下实现shift select功能, 参考:
###   https://stackoverflow.com/questions/5407916/zsh-zle-shift-selection

r-delregion() {
    if ((REGION_ACTIVE)) then
        zle kill-region
    else
        local widget_name=$1
        shift
        zle $widget_name -- $@
    fi
}

r-deselect() {
    ((REGION_ACTIVE = 0))
    local widget_name=$1
    shift
    zle $widget_name -- $@
}

r-select() {
    ((REGION_ACTIVE)) || zle set-mark-command
    local widget_name=$1
    shift
    zle $widget_name -- $@
}

r-bind-key() {
    key=$1
    seq=$2
    mode=$3
    widget=$4
    shift 4
    ### 定义每一个键的函数
    eval "key-${key}() {
       r-${mode} ${widget} \$@
    }
    zle -N key-${key}
    bindkey \"${seq}\" key-${key}
    "
}

### only for copy-region-as-kill
r-copyregion() {
    if ((REGION_ACTIVE)) then
       zle copy-region-as-kill
       ((REGION_ACTIVE = 0))
    fi
}
zle -N r-copyregion

################################# key binding ##################################

### 常规键, 按下之后取消选择
r-bind-key  left     "\eOD"    deselect  backward-char
r-bind-key  right    "\eOC"    deselect  forward-char
r-bind-key  c-left   "\e[D"    deselect  backward-word
r-bind-key  c-right  "\e[C"    deselect  forward-word
r-bind-key  m-left   "\e\eOD"  deselect  backward-word
r-bind-key  m-right  "\e\eOC"  deselect  forward-word
r-bind-key  home     "\e[1~"   deselect  beginning-of-line
r-bind-key  end      "\e[4~"   deselect  end-of-line
r-bind-key  c-home   "\e[a1~"  deselect  beginning-of-line
r-bind-key  c-end    "\e[a4~"  deselect  end-of-line
r-bind-key  up       "\eOA"    deselect  up-line-or-history
r-bind-key  down     "\eOB"    deselect  down-line-or-history

### Shift修饰的键, 按下之后开始选择
r-bind-key  s-left    "\e[bD"   select  backward-char
r-bind-key  s-right   "\e[bC"   select  forward-char
r-bind-key  cs-left   "\e[dD"   select  backward-word
r-bind-key  cs-right  "\e[dC"   select  forward-word
r-bind-key  s-home    "\e[b1~"  select  beginning-of-line
r-bind-key  s-end     "\e[b4~"  select  end-of-line
r-bind-key  cs-home   "\e[d1~"  select  beginning-of-line
r-bind-key  cs-end    "\e[d4~"  select  end-of-line
r-bind-key  s-up      "\e[bA"   select  up-line-or-history
r-bind-key  s-down    "\e[bB"   select  down-line-or-history

### 删除键, 按下之后删除选中的文字
r-bind-key  delete       "\e[3~"    delregion  delete-char
r-bind-key  backspace    "\b"       delregion  backward-delete-char
r-bind-key  c-backspace  "\e[aF"    delregion  backward-kill-word
r-bind-key  c-delete     "\e[a3~"   delregion  kill-word
r-bind-key  m-backspace  "\e[cF"    delregion  backward-kill-word
r-bind-key  m-delete     "\e\e[3~"  delregion  kill-word

### 其他按键, 模拟emacs
### zsh中, 先按C-v, 再按目标键可以得到该键的字符序列
bindkey  "^w"   kill-region   #  C-w
bindkey  "^[w"  r-copyregion  #  M-w
