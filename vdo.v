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
	tasks []Task
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
	}, [ui.column({}, tasks(app))])

	ui.run(window)
}

fn tasks(app &State) []ui.Widget {
	mut tasks := []ui.Widget{}

	for task in app.tasks {
		tasks << ui.row({}, [
			ui.checkbox(checked: task.done),
			ui.label(text: task.title),
		])
	}

	return tasks
}
