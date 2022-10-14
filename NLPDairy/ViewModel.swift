//
//  ViewModel.swift
//  NLPDairy
//
//  Created by Khawlah Khalid on 14/10/2022.
//

import Foundation


final class ViewModel : ObservableObject{
    
    let entryCollection: [String]
    @Published var filteredEntries = [String]()
    @Published  var searchText = ""
    
    var wordSets = [String: Set<String>]()
    var languages = [String: String]()
    
    
    var searchResults: [String] {
        if searchText.isEmpty {
            return entryCollection
        } else {
            extractWordSetsAndLanguages()
            filterEntries()
            return filteredEntries
        }
    }
    
    
    init() {
        self.entryCollection = EntryCollection().entries!
        filteredEntries = self.entryCollection
    }
    
    
    fileprivate func setOfWords(string: String, language: inout String?) -> Set<String> {
        var wordSet = Set<String>()
        
        let tagger = NSLinguisticTagger(tagSchemes: [.lemma, .language], options: 0)
        let range = NSRange(location: 0, length: string.utf16.count)
        
        tagger.string  = string
        
        if let language = language {
            let orthography = NSOrthography.defaultOrthography(forLanguage: language)
            tagger.setOrthography(orthography, range: range)
        }else{
            language = tagger.dominantLanguage
        }
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: [.omitWhitespace, .omitPunctuation]){
            tag, tokenRange, _ in
            
            let token = (string as NSString).substring(with: tokenRange)
            wordSet.insert(token.lowercased())
            
            if let lemma = tag?.rawValue {
                wordSet.insert(lemma.lowercased())
            }
            
        }
        return wordSet
    }
    
    
     func extractWordSetsAndLanguages() {
        var newWordSets = [String: Set<String>]()
        var newLanguages = [String: String]()
        
        for entry in entryCollection {
            if let wordSet = wordSets[entry] {
                
                newWordSets[entry] = wordSet
                newLanguages[entry] = languages[entry]
            } else {
                
                var language: String?
                let wordSet = setOfWords(string: entry, language: &language)
                newWordSets[entry] = wordSet
                newLanguages[entry] = language
            }
        }
        
        wordSets = newWordSets
        languages = newLanguages
    }
    
    
    func filterEntries() {
        var language: String?
        DispatchQueue.main.async { [self] in

            var filterSet = setOfWords(string: searchText, language: &language)
            
            for existingLanguage in Set<String>(languages.values) {
                
                language = existingLanguage
                filterSet = filterSet.union(setOfWords(string: searchText, language: &language))
            }
            
            filteredEntries.removeAll()
           
            
            if filterSet.isEmpty {
                filteredEntries.append(contentsOf: entryCollection)
            } else {
                let simpleResults = entryCollection.filter {$0.lowercased().contains(searchText.lowercased())}
                filteredEntries.append(contentsOf: simpleResults)
                
                for entry in entryCollection {
                    guard let wordSet = wordSets[entry], !wordSet.intersection(filterSet).isEmpty else { continue }
                    filteredEntries.append(entry)
                }
            }
        }
    }
    
}

