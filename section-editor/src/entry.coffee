import h from '@macrostrat/hyper'
import {render} from 'react-dom'
import {App} from './app'

el = document.querySelector("#app")
render(h(App), el)
