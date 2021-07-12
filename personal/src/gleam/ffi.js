export function arrayToList(items) {
    return items.reduceRight((tail, item) => [item, tail], [])
}

export function listToArray(list) {
    let array = []
    while (list.length === 2) {
        let [value, inner] = list
        array.push(value)
        list = inner
    }
    return array
}