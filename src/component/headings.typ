#import "../constants.typ": default-heading-margin

#let structural-heading-titles = (
  performers: [Список исполнителей],
  abstract: [Реферат],
  contents: [Содержание],
  terms: [Термины и определения],
  abbreviations: [Перечень сокращений и обозначений],
  intro: [Введение],
  conclusion: [Заключение],
  references: [Список использованных источников],
)

#let structure-heading-style = it => {
  // Структурные заголовки: по центру, ПРОПИСНЫМИ, полужирные по ГОСТ
  align(center)[#text(weight: "bold")[#upper(it)]]
}

#let structure-heading(body) = {
  structure-heading-style(heading(numbering: none)[#body])
}

#let headings(text-size, indent, add-pagebreaks) = body => {
  // Все заголовки полужирные по ГОСТ 7.32-2017
  show heading: set text(size: text-size, weight: "bold")
  set heading(numbering: "1.1")

  // Заголовки подразделов (2+) с абзацного отступа
  show heading.where(level: 2): it => {
    pad(it, left: indent)
  }
  show heading.where(level: 3): it => {
    pad(it, left: indent)
  }

  show heading.where(level: 1): it => {
    if add-pagebreaks {
      pagebreak(weak: true)
    }
    // Заголовки первого уровня: ПРОПИСНЫМИ, по центру, полужирные по ГОСТ
    if it.body not in structural-heading-titles.values() {
      align(center)[#counter(heading).display(it.numbering) #upper(it.body)]
    } else {
      it
    }
  }

  let structural-heading = structural-heading-titles
    .values()
    .fold(selector, (acc, i) => acc.or(heading.where(body: i, level: 1)))

  show structural-heading: set heading(numbering: none)
  show structural-heading: it => {
    if add-pagebreaks {
      pagebreak(weak: true)
    }
    structure-heading-style(it)
  }

  show heading: set block(..default-heading-margin)

  body
}
