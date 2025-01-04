#!/usr/bin/env node

import {Parser, NamedNode, Store, Writer, Quad, DataFactory} from 'n3'
import {createReadStream} from 'node:fs'
import {Readable} from 'node:stream'
import {QueryEngine} from '@comunica/query-sparql-rdfjs'

const {quad, namedNode, defaultGraph} = DataFactory

const bob = "https://daseinonline.xyz/coffee-bob/taxonomy/"
const prefixes = {}

const myEngine = new QueryEngine()

const parser = new Parser()
const source = await fetch(new URL('https://raw.githubusercontent.com/aljedaxi/dasein-online/refs/heads/main/resources/specs.ttl'))
// const rdfStream = createReadStream('path to source file')
const rdfStream = Readable.fromWeb(source.body)
const store = await new Promise((res, rej) => {
    const store = new Store()
    parser.parse(rdfStream, (error, quad, fixes) => {
        if (error) rej(error)
        if (quad === null) {
            Object.assign(prefixes, fixes)
            res(store)
            return
        }
        store.add(quad)
    })
})
const subFeature = store.getPredicates().find(({id}) => /subFeature/i.test(id))
const pickle = (...quads) => {
    const writer = new Writer({prefixes})
    for (const quad of quads) writer.addQuad(quad)
    return new Promise(res => writer.end((err, result) => res(result)))
}
const query = (sparql, ...sources) => myEngine.queryBindings(sparql, {sources})
const what = await query(`SELECT * WHERE { ?s ?p ?o }`, store)
const searchedQuads = (await what.toArray()).map(b => {
    const {s,p,o} = Object.fromEntries(b.entries.entries())
    return quad(s,p,o)
})
console.log(searchedQuads)
pickle(...searchedQuads).then(console.log)
// pickle(...store.match(namedNode(`${bob}Coffee`), subFeature)).then(console.log)
