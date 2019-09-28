# vim-hello-word

一个用来背单词的 (Neo)Vim 工具

## 安装

- vim-plug

```vim
Plug 'voldikss/vim-hello-word', {'on': ['HelloWord', ['HelloWordSetVocabulary']]}
```

- dein.nvim

```vim
call dein#add('voldikss/vim-hello-word', {'on_cmd': ['HelloWord', 'HelloWordSetVocabulary']})
```

## 特性

- 多模式出题(选择：英汉&汉英，拼写：汉英)
- 可以导出答错的单词为 json 文件

## 用法

#### **`g:helloword_vocabulary_path`**

词库文件的路径，也可以使用 `:HelloWordSetVocabulary` 进行设置

**注：词库的格式参照[CET6.json](./test/CET6.json)**

#### `:HelloWord`

开始答题

#### `:HelloWordExport`

导出答错的单词为 json 文件

#### `:HelloWordSetVocabulary`

设置词库的路径，可以使用 `<Tab>` 进行补全，也可以使用 `g:helloword_vocabulary_path` 进行设置

## Screenshots

<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/62780836-2c9ace80-bae9-11e9-8ad5-4404c3032b67.png" width=800>
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/62780838-2c9ace80-bae9-11e9-932a-38d84de23ded.png" width=800>
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/62780839-2c9ace80-bae9-11e9-840f-2266e52c1298.png" width=800>
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/62780478-58698480-bae8-11e9-9ba2-6cc3c35d75cc.png" width=800>
</div>

## License

MIT
