# vim-hello-word

一个用来背单词的 (Neo)Vim 工具

## 安装

- vim-plug

```vim
Plug 'voldikss/vim-hello-word', {'on': ['HelloWord', ['HelloWordSetLexicon']]}
```

- dein.nvim

```vim
call dein#add('voldikss/vim-hello-word', {'on_cmd': ['HelloWord', 'HelloWordSetLexicon']})
```

## 特性

- 多模式出题(选择：英汉&汉英，拼写：汉英)
- 可以导出答错的单词为 json 文件

## 配置

#### **`g:helloword_lexicon_path`**

> 词库文件的路径，测试词库在这[CET6.json](./test/CET6.json)

也可以使用 `:HelloWordSetLexicon` 进行设置

## 命令

#### `:HelloWord`

开始答题

#### `:HelloWordExport`

导出答错的单词为 json 文件

#### `:HelloWordSetLexicon`

设置词库的路径，可以使用 `<Tab>` 进行补全，也可以使用 `g:helloword_lexicon_path` 进行设置

## Screenshots

<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/62772626-9c518f00-bad2-11e9-878c-86dd466e2bcf.png" width=800>
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/62772628-9c518f00-bad2-11e9-94e7-f48727df9a0c.png" width=800>
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/62772631-9cea2580-bad2-11e9-87d2-65ed7dd98a50.png" width=800>
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/62772624-9c518f00-bad2-11e9-80b7-086c3b178d3a.png" width=800>
</div>

## License

MIT

