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
	tasks  []Task
	window &ui.Window = voidptr(0)
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
			ui.column({ heights: ui.compact }, tasks(app)), ui.button(text: '+', onclick: add_task)]),
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
	return ui.row({}, [
		ui.checkbox(checked: task.done),
		ui.label(text: task.title),
	])
}

fn entries_column(w &ui.Window) ?&ui.Stack {
	s := w.child(0)
	if mut s is ui.Stack {
		return s
	}

	return error('Cannot find entries column')
}

fn add_task(mut app State, btn &ui.Button) {
	new_task := Task{
		title: 'new'
		done: false
	}
	app.tasks << new_task

	window := btn.ui.window

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

	s.margins.top = f32_min(0, s.margins.top - f32(e.y))

	w.update_layout()
}
