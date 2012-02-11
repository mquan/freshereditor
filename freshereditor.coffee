(($)->
	methods = 
		edit: (isEditing)-> 
			this.each -> 
				$(this).attr("contentEditable", isEditing||false)
		save: (callback)->
			this.each ->
				(callback)($(this).attr('id'), $(this).html())
		createlink: ->
			urlPrompt = prompt("Enter URL:", "http://")
			document.execCommand("createlink", false, urlPrompt)
		insertimage: ->
			urlPrompt = prompt("Enter Image URL:", "http://")
			document.execCommand("insertimage", false, urlPrompt)
		formatblock: (block)->
			document.execCommand("formatblock", null, block)
		init: (opts)->
			options = opts || {}
			#build toolbar
			groups = [
				[
					{name: 'bold', label: "<span style='font-weight:bold;'>B</span>", title: 'Bold (Ctrl+B)', classname: 'toolbar_bold'},
					{name: 'italic', label: "<span style='font-style:italic;'>I</span>", title: 'Italic (Ctrl+I)', classname: 'toolbar_italic'},
					{name: 'underline', label: "<span style='text-decoration:underline!important;'>U</span>", title: 'Underline (Ctrl+U)', classname: 'toolbar_underline'},
					{name: 'strikethrough', label: "<span style='text-shadow:none;text-decoration:line-through;'>ABC</span>", title: 'Strikethrough', classname: 'toolbar_strikethrough'},
					{name: 'removeFormat', label: "<i class='icon-minus'></i>", title: 'Remove Formating (Ctrl+M)', classname: 'toolbar_remove'}
				],
				[{name: 'fontname', label: "F <span class='caret'></span>", title: 'Select font name', classname: 'toolbar_fontname dropdown-toggle', dropdown: true}],
				[{name: 'FontSize', label: "<span style='font:bold 16px;'>A</span><span style='font-size:8px;'>A</span> <span class='caret'></span>", title: 'Select font size', classname: 'toolbar_fontsize dropdown-toggle', dropdown: true}],
				[{name: 'forecolor', label: "<div style='color:#ff0000;'>A <span class='caret'></span></div>", title: 'Select font color', classname: 'toolbar_forecolor dropdown-toggle', dropdown: true}],
				[{name: 'backcolor', label: "<div style='display:inline-block;margin:3px;width:15px;height:12px;background-color:#0000ff;'></div> <span class='caret'></span>", title: 'Select background color', classname: 'toolbar_bgcolor dropdown-toggle', dropdown: true}],
				[
					{name: 'justifyleft', label: "<i class='icon-align-left' style='margin-top:2px;'></i>", title: 'Left justify', classname: 'toolbar_justifyleft'},
					{name: 'justifycenter', label: "<i class='icon-align-center' style='margin-top:2px;'></i>", title: 'Center justify', classname: 'toolbar_justifycenter'},
					{name: 'justifyright', label: "<i class='icon-align-right' style='margin-top:2px;'></i>", title: 'Right justify', classname: 'toolbar_justifyright'},
					{name: 'justifyfull', label: "<i class='icon-align-justify' style='margin-top:2px;'></i>", title: 'Full justify', classname: 'toolbar_justifyfull'}
				],
				[
					{name: 'createlink', label: '@', title: 'Link to a web page (Ctrl+L)', userinput: "yes", classname: 'toolbar_link'},
					{name: 'insertimage', label: "<i style='margin-top:2px;' class='icon-picture'></i>", title: 'Insert an image (Ctrl+G)', userinput: "yes", classname: 'toolbar_image'},
					{name: 'insertorderedlist', label: "<i class='icon-list-alt' style='margin-top:2px;'></i>", title: 'Insert ordered list', classname: 'toolbar_ol'},
					{name: 'insertunorderedlist', label: "<i class='icon-list' style='margin-top:2px;'></i>", title: 'Insert unordered list', classname: 'toolbar_ul'}
				],
				[
					{name: 'insertparagraph', label: 'P', title: 'Insert a paragraph (Ctrl+Alt+0)', classname: 'toolbar_p', block:'p'},
					{name: 'insertheading1', label: 'H1', title: "Heading 1 (Ctrl+Alt+1)", classname: 'toolbar_h1', block: 'h1'},
					{name: 'insertheading2', label: 'H2', title: "Heading 2 (Ctrl+Alt+2)", classname: 'toolbar_h2',  block: 'h2'},
					{name: 'insertheading3', label: 'H3', title: "Heading 3 (Ctrl+Alt+3)", classname: 'toolbar_h3', block: 'h3'},
					{name: 'insertheading4', label: 'H4', title: "Heading 4 (Ctrl+Alt+4)", classname: 'toolbar_h4', block: 'h4'}
				],
				[
					{name: 'blockquote', label: "<i style='margin-top:2px;' class='icon-comment'></i>", title: 'Blockquote (Ctrl+Q)', classname: 'toolbar_blockquote', block:'blockquote'},
					{name: 'code', label: '{&nbsp;}', title: 'Code (Ctrl+Alt+K)', classname: 'toolbar_code', block:'pre'},
					{name: 'superscript', label: 'x<sup>2</sup>', title: 'Superscript', classname: 'toolbar_superscript'},
					{name: 'subscript', label: 'x<sub>2</sub>', title: 'Subscript', classname: 'toolbar_subscript'}
				]
			]
			
			if options.toolbar_selector?
				$toolbar = $(options.toolbar_selector)
			else
				$(this).before("<div id='editor-toolbar'></div>")
				$toolbar = $('#editor-toolbar')
			$toolbar.addClass('fresheditor-toolbar')
			$toolbar.append("<div class='btn-toolbar'></div>")
			excludes = options.excludes || []
			for commands in groups
				group = ''
				for command in commands
					if jQuery.inArray(command.name, excludes) < 0
						button = "<a href='#' class='btn toolbar-btn toolbar-cmd #{command.classname}' title='#{command.title}' command='#{command.name}'"
						button += " userinput='#{command.userinput}'" if command.userinput?
						button += " block='#{command.block}'" if command.block?
						button += " data-toggle='dropdown'" if command.dropdown
						button += ">#{command.label}</a>"
						group += button
				$('.btn-toolbar', $toolbar).append("<div class='btn-group'>#{group}</div>")
			$("[data-toggle='dropdown']").removeClass('toolbar-cmd')
			
			#fontname dropdown menu
			fontnames = ["Arial", "Arial Black", "Comic Sans MS", "Courier New", "Georgia", "Helvetica", "Sans Serif", "Tahoma", "Times New Roman", "Trebuchet MS", "Verdana"]
			font_list = ''
			font_list += "<li><a href='#' class='fontname-option' style='font-family:#{font};'>#{font}</a></li>" for font in fontnames
			$('.toolbar_fontname').after("<ul class='dropdown-menu'>#{font_list}</ul>")
			$('.fontname-option').on 'click', ->
				document.execCommand("fontname", false, $(this).text())
				$(this).closest('.btn-group').removeClass('open')
				false
			
			#fontsize dropdown
			fontsizes = [{size: 1, point: 8}, {size:2, point:10}, {size:3, point:12}, {size:4, point:14},{size:5, point:18}, {size:6, point:24}, {size:7, point:36}]
			size_list = ''
			size_list += "<li><a href='#' class='font-option fontsize-option' style='font-size:#{fontsize.point}px;fontsize='#{fontsize.size}'>#{fontsize.size}(#{fontsize.point}pt)</a></li>" for fontsize in fontsizes
			$('.toolbar_fontsize').after("<ul class='dropdown-menu'>#{size_list}</ul>")
			$('a.fontsize-option').on 'click', ->
				document.execCommand("FontSize", false, $(this).attr('fontsize'))
				$(this).closest('.btn-group').removeClass('open')
				false
			
			#forecolor dropdown
			$('a.toolbar_forecolor').after("<ul class='dropdown-menu colorpanel'><input type='text' id='forecolor-input' value='#000000' /><div id='forecolor-picker'></div></ul>")
			$('#forecolor-picker').farbtastic (color)->
				$('#forecolor-input').val(color)
				document.execCommand("forecolor", false, color)
				$(this).closest('.btn-group').removeClass('open')
				$('.toolbar_forecolor div').css({"color": color})
				false
			
			#bgcolor dropdown
			$('a.toolbar_bgcolor').after("<ul class='dropdown-menu colorpanel'><input type='text' id='bgcolor-input' value='#000000' /><div id='bgcolor-picker'></div></ul>");
			$('#bgcolor-picker').farbtastic (color)->
				$('#bgcolor-input').val(color)
				document.execCommand("backcolor", false, color)
				$(this).closest('.btn-group').removeClass('open')
				$('.toolbar_bgcolor div').css({"background-color": color})
				return false
			
			$(this).on('focus', ->
				$this = $(this)
				$this.data('before', $this.html())
				$this
			).on 'blur keyup paste', ->
				$this = $(this)
				if $this.data('before') isnt $this.html()
					$this.data('before', $this.html())
					$this.trigger('change')
				$this

			$("a.toolbar-cmd").on 'click', ->
				cmd = $(this).attr('command')
				if $(this).attr('userinput') is 'yes'
					methods[cmd].apply(this)
				else if $(this).attr('block')
					methods['formatblock'].apply(this, ["<#{$(this).attr('block')}>"])
				else
					#Firefox execCommand fix for justify (https://bugzilla.mozilla.org/show_bug.cgi?id=442186)
					if (cmd is 'justifyright') or (cmd is 'justifyleft') or (cmd is 'justifycenter') or (cmd is 'justifyfull')
						try
                    		document.execCommand(cmd, false, null)
						catch e
                            #special case for Mozilla Bug #442186
							if e and e.result is 2147500037
								#probably firefox bug 442186 - workaround
								range = window.getSelection().getRangeAt(0)
								dummy = document.createElement('br')
								
								#find node with contentEditable
								ceNode = range.startContainer.parentNode
								while ceNode? and ceNode.contentEditable isnt 'true'
									ceNode = ceNode.parentNode
													
								throw 'Selected node is not editable!' if !ceNode
								ceNode.insertBefore(dummy, ceNode.childNodes[0])             
								document.execCommand(cmd, false, null)
								dummy.parentNode.removeChild(dummy)
							else if (console and console.log) 
								console.log(e)
					else
						document.execCommand(cmd, false, null)
				false

			shortcuts = [
				{keys: 'Ctrl+l', method: -> methods.createlink.apply(this) }
				{keys: 'Ctrl+g', method: -> methods.insertimage.apply(this) }
				{keys: 'Ctrl+Alt+U', method: -> document.execCommand('insertunorderedlist', false, null) }
				{keys: 'Ctrl+Alt+O', method: -> document.execCommand('insertorderedlist', false, null) }
				{keys: 'Ctrl+q', method: -> methods.formatblock.apply(this, ["<blockquote>"]) }
				{keys: 'Ctrl+Alt+k', method: -> methods.formatblock.apply(this, ["<pre>"]) }
				{keys: 'Ctrl+.', method: -> document.execCommand('superscript', false, null) }
				{keys: 'Ctrl+Shift+.', method: -> document.execCommand('subscript', false, null) }
				{keys: 'Ctrl+Alt+0', method: -> methods.formatblock.apply(this, ["p"]) }
				{keys: 'Ctrl+b', method: -> document.execCommand('bold', false, null) }
				{keys: 'Ctrl+i', method: -> document.execCommand('italic', false, null) }
				{keys: 'Ctrl+Alt+1', method: -> methods.formatblock.apply(this, ["H1"]) }
				{keys: 'Ctrl+Alt+2', method: -> methods.formatblock.apply(this, ["H2"]) }
				{keys: 'Ctrl+Alt+3', method: -> methods.formatblock.apply(this, ["H3"]) }
				{keys: 'Ctrl+Alt+4', method: -> methods.formatblock.apply(this, ["H4"]) }
				{keys: 'Ctrl+m', method: -> document.execCommand("removeFormat", false, null) }
				{keys: 'Ctrl+u', method: -> document.execCommand('underline', false, null) }
				{keys: 'tab', method: -> document.execCommand('indent', false, null) }
				{keys: 'Ctrl+tab', method: -> document.execCommand('indent', false, null) }
				{keys: 'Shift+tab', method: -> document.execCommand('outdent', false, null) }
			]
				
			$.each shortcuts, (index, elem)->
				shortcut.add(elem.keys, ->
					elem.method()
					false
				, {'type': 'keydown', 'propagate': false})

			return this.each ->
				$this = $(this)
				data = $this.data('fresheditor')
				tooltip = $('<div/>', {text: $this.attr('title')})
				
				#if plugin hasnt been initialized
				$(this).data('fresheditor', {target: $this, tooltip: tooltip}) if !data

	$.fn.freshereditor = (method)->
		if methods[method]
			methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
		else if typeof(method) is 'object' or !method
			methods.init.apply(this, arguments)
		else
			$.error('Method ' + method + ' does not exist on jQuery.contentEditable')
		return
)(jQuery)