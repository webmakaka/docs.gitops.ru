---
layout: page
title: Настройка neovim для работы с языком Rust
description: Настройка neovim для работы с языком Rust
keywords: rust, neovim
permalink: /dev/rust/neovim/
---

<br/>

# Настройка neovim для работы с языком Rust

<br/>

Neovim пока как и [здесь](//jsdev.org/devtools/ide/neovim/)

<br/>

```
$ cargo new rusttests
$ cd rusttests
$ vi ./
```

<!-- <br/>

```
// Не знаю зачем. Наверное, чтобы не было ошибки!

$ sudo apt-get install ctags
$ cargo install rusty-tags
``` -->

https://rust-analyzer.github.io/manual.html#vimneovim

<br/>

```
:CocInstall coc-rust-analyzer
```

<br/>

```
$ rustup component add rustfmt
$ cargo fmt
```
