#import "../component/title.typ": (
  approved-and-agreed-fields, detailed-sign-field, per-line,
)
#import "../utils.typ": fetch-field, sign-field

/// Функция для обработки аргументов шаблона Московского Политеха
#let arguments(..args, year: auto) = {
  let args = args.named()
  
  args.organization = fetch-field(
    args.at("organization", default: none),
    default: (
      full: "Московский Политехнический Университет",
      short: none,
    ),
    ("*full", "short"),
    hint: "организации",
  )

  args.faculty = fetch-field(
    args.at("faculty", default: none),
    ("name",),
    default: (name: none),
    hint: "факультета",
  )

  args.department = fetch-field(
    args.at("department", default: none),
    ("name",),
    default: (name: none),
    hint: "кафедры",
  )

  args.approved-by = fetch-field(
    args.at("approved-by", default: none),
    ("name*", "position*", "year"),
    default: (year: auto),
    hint: "согласования",
  )
  
  args.agreed-by = fetch-field(
    args.at("agreed-by", default: none),
    ("name*", "position*", "year"),
    default: (year: auto),
    hint: "утверждения",
  )

  args.stage = fetch-field(
    args.at("stage", default: none),
    ("type*", "num"),
    hint: "этапа",
  )

  args.manager = fetch-field(
    args.at("manager", default: none),
    ("position*", "name*", "title"),
    default: (title: "Руководитель НИР,"),
    hint: "руководителя",
  )

  if args.approved-by.year == auto {
    args.approved-by.year = year
  }
  if args.agreed-by.year == auto {
    args.agreed-by.year = year
  }

  return args
}

/// Шаблон титульного листа для Московского Политехнического Университета
#let template(
  ministry: "МИНИСТЕРСТВО НАУКИ И ВЫСШЕГО ОБРАЗОВАНИЯ РОССИЙСКОЙ ФЕДЕРАЦИИ",
  organization: (
    full: "Московский Политехнический Университет",
    short: none,
  ),
  faculty: (name: none),
  department: (name: none),
  logo: none,
  udk: none,
  research-number: none,
  report-number: none,
  approved-by: (name: none, position: none, year: auto),
  agreed-by: (name: none, position: none, year: none),
  report-type: "Отчёт",
  about: none,
  bare-subject: false,
  research: none,
  subject: none,
  part: none,
  stage: none,
  federal: none,
  manager: (position: none, name: none, title: none),
  performer: none,
) = {
  // Логотип в левом верхнем углу (не смещает текст)
  if logo != none {
    place(top + left, image(logo, height: 2cm))
    v(2.5cm)  // Отступ чтобы текст не пересекался с логотипом
  }

  // Министерство и организация
  per-line(
    force-indent: true,
    ministry,
    (value: [Федеральное государственное автономное], when-present: organization.full),
    (value: [образовательное учреждение высшего образования], when-present: organization.full),
    (value: upper[«#organization.full»], when-present: organization.full),
    (value: upper[(#organization.short)], when-present: organization.short),
  )

  // Факультет и кафедра
  per-line(
    force-indent: true,
    (value: faculty.name, when-present: faculty.name),
    (value: department.name, when-present: department.name),
  )

  // УДК и регистрационные номера
  per-line(
    force-indent: true,
    align: left,
    (value: [УДК: #udk], when-present: udk),
    (value: [Рег. №: #research-number], when-present: research-number),
    (value: [Рег. № ИКРБС: #report-number], when-present: report-number),
  )

  // Блоки согласования и утверждения
  approved-and-agreed-fields(approved-by, agreed-by)

  // Тип работы и тема
  per-line(
    align: center,
    indent: 2fr,
    (value: upper(report-type), when-present: report-type),
    (value: upper(about), when-present: about),
    (value: research, when-present: research),
    (value: [по теме:], when-rule: not bare-subject),
    (value: upper(subject), when-present: subject),
    (
      value: [(#stage.type)],
      when-rule: (stage.type != none and stage.num == none),
    ),
    (
      value: [(#stage.type, этап #stage.num)],
      when-present: (stage.type, stage.num),
    ),
    (value: [\ Книга #part], when-present: part),
    (federal),
  )

  // Руководитель с полем подписи
  if manager.name != none {
    let title = if type(manager.title) == str and manager.title != "" {
      manager.title + linebreak()
    } else {
      none
    }
    sign-field(manager.at("name"), [#title #manager.at("position")])
  }

  // Исполнитель с полем подписи
  if performer != none {
    let title = if type(performer.at("title", default: none)) == str {
      performer.title + linebreak()
    } else {
      none
    }
    sign-field(
      performer.at("name", default: none),
      [#title #performer.at("position", default: none)],
      part: performer.at("part", default: none),
    )
  }

  v(0.5fr)
}
