import ui

const (
	w_width  = 400
	w_height = 600
	w_title  = 'V DO'
)

struct Task {
mut:
	title string
	done  bool
}

struct State {
mut:
	tasks      []Task
	input      string
	edit_input string
	edit_index int        = -1
	window     &ui.Window = voidptr(0)

	edit bool // workaround prevent double call of click handler
}

fn main() {
	mut app := &State{
		tasks: [
			{
				title: 'test'
				done: false
			},
			{
				title: 'test 2'
				done: false
			},
		]
	}

	window := ui.window({
		width: w_width
		height: w_height
		state: app
		title: w_title
		mode: .resizable
		on_scroll: on_scroll
	}, [
		ui.column({ margin_: 8, heights: [ui.stretch, ui.compact] }, [
			ui.column({ heights: ui.compact, spacing: 4 }, tasks(app)),
			ui.row({ widths: [ui.stretch, ui.compact], spacing: 4 }, [
				ui.textbox(text: &app.input, on_enter: on_enter),
				ui.button(text: '+', onclick: btn_add_task),
			]),
		]),
	])

	app.window = window
	ui.run(window)
}

fn tasks(app &State) []ui.Widget {
	mut tasks := []ui.Widget{}

	for task in app.tasks {
		tasks << entry(task)
	}

	return tasks
}

fn entry(task Task) &ui.Stack {
	return ui.row({ widths: [ui.compact, ui.stretch, ui.compact], spacing: 4 }, [
		ui.checkbox(checked: task.done),
		ui.label(text: task.title),
		ui.button(text: 'E', onclick: btn_edit_task),
	])
}

fn edit_entry(mut app State, task Task) &ui.Stack {
	app.edit_input = task.title

	return ui.row({ widths: [ui.stretch, ui.compact], spacing: 4 }, [
		ui.textbox(text: &app.edit_input, on_enter: txb_enter_edit, is_focused: true),
		ui.button(text: 'D', onclick: btn_remove_task),
	])
}

fn entries_column(w &ui.Window) ?&ui.Stack {
	s := w.child(0)
	if mut s is ui.Stack {
		return s
	}

	return error('Cannot find entries column')
}

fn btn_add_task(mut app State, btn &ui.Button) {
	add_task(mut app, btn.ui.window)
}

fn btn_edit_task(mut app State, btn &ui.Button) {
	row := btn.parent

	if mut row is ui.Stack {
		id := row.id
		mut column := row.parent

		if mut column is ui.Stack {
			index := child_index(column, id)
			if index > -1 {
				column.remove(at: index)
				column.add(at: index, child: edit_entry(mut app, app.tasks[index]))
				app.edit = true
				app.edit_index = index
			}
		}
	}
}

fn btn_remove_task(mut app State, btn &ui.Button) {
	if app.edit {
		app.edit = false
		return
	}

	row := btn.parent

	if mut row is ui.Stack {
		mut column := row.parent

		if mut column is ui.Stack {
			if app.edit_index > -1 {
				column.remove(at: app.edit_index)
				app.tasks.delete(app.edit_index)
				app.edit_index = -1
			}
		}
	}
}

fn txb_enter_edit(text string, mut app State) {
	if app.edit_index < 0 {
		return
	}

	app.tasks[app.edit_index].title = text

	mut s := entries_column(app.window) or {
		println(err)
		return
	}

	s.remove(at: app.edit_index)
	s.add(
		at: app.edit_index
		child: entry(app.tasks[app.edit_index])
	)

	// app.window.unfocus_all()
	app.edit_index = -1
}

// Gets the index of child by id on the given stack. If the child is not found -1 will be returned.
fn child_index(parent &ui.Stack, id string) int {
	for i in 0 .. parent.children.len {
		child := parent.children[i]

		if child is ui.Stack {
			if child.id == id {
				return i
			}
		}
	}

	return -1
}

fn add_task(mut app State, window &ui.Window) {
	new_task := Task{
		title: app.input
		done: false
	}
	app.tasks << new_task
	app.input = ''

	mut s := entries_column(window) or {
		println(err)
		return
	}

	s.add(
		child: entry(new_task)
	)

	window.update_layout()
}

fn on_scroll(e ui.ScrollEvent, w &ui.Window) {
	mut s := entries_column(w) or {
		println(err)
		return
	}

	mut content_height := 0

	for mut c in s.children {
		_, h := c.size()
		content_height += h
	}

	if s.real_height - content_height >= 0 {
		s.margins.top = 0
	} else {
		s.margins.top = f32_max(f32_min(0, s.margins.top - f32(e.y)), s.real_height - content_height)
	}

	w.update_layout()
}

fn on_enter(_ string, mut app State) {
	add_task(mut app, app.window)
}
