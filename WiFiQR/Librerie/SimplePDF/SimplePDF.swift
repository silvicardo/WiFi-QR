//
//  SimplePDF.swift
//
//  Created by Muhammad Ishaq on 22/03/2015.
//

import Foundation
import UIKit
import ImageIO
import CoreText
//import XCGLogger

/**
 *  Generate Simple Documents with Images. TOC gets generated and put at (roughly) specified page index
 */
public class SimplePDF {
    // MARK: - Document Structure
    class DocumentStructure {
        // MARK: - FunctionCall (sort of a "Command" pattern)
        enum FunctionCall : CustomStringConvertible {
            case addH1(string: String, backgroundBoxColor: UIColor?)
            case addH2(string: String, backgroundBoxColor: UIColor?)
            case addH3(string: String, backgroundBoxColor: UIColor?)
            case addH4(string: String, backgroundBoxColor: UIColor?)
            case addH5(string: String, backgroundBoxColor: UIColor?)
            case addH6(string: String, backgroundBoxColor: UIColor?)
            case addBodyText(string: String, backgroundBoxColor: UIColor?)
            case startNewPage
            case addImages(imagePaths:[String], imageCaptions: [String], imagesPerRow:Int, spacing:CGFloat, padding:CGFloat)
            case addImagesRow(imagePaths: [String], imageCaptions: [NSAttributedString], columnWidths: [CGFloat],
                spacing: CGFloat, padding: CGFloat, captionBackgroundColor: UIColor?, imageBackgroundColor: UIColor?)
            case addAttributedStringsToColumns(columnWidths: [CGFloat], strings: [NSAttributedString], horizontalPadding: CGFloat, allowSplitting: Bool, backgroundColor: UIColor?)
            case addView(view: UIView)
            
            var description: String {
                get {
                    switch(self) {
                    case .addH1(let string, _):
                        return "addH1 (\(string))"
                    case .addH2(let string, _):
                        return "addH2 (\(string))"
                    case .addH3(let string, _):
                        return "addH3 (\(string))"
                    case .addH4(let string, _):
                        return "addH4 (\(string))"
                    case .addH5(let string, _):
                        return "addH5 (\(string))"
                    case .addH6(let string, _):
                        return "addH6 (\(string))"
                    case .addBodyText(let string, _):
                        return "addBodyText (\(string.substring(to: string.index(string.startIndex, offsetBy: 25))))"
                    case .startNewPage:
                        return "startNewPage"
                    case .addImages:
                        return "addImages"
                    case .addImagesRow:
                        return "addImagesRow"
                    case .addAttributedStringsToColumns:
                        return "addAttributedStringsToColumns"
                    case .addView:
                        return "addView"
                    }
                    
                }
            }
            
            func execute(_ pdf: PDFWriter, calculationOnly: Bool = true) -> NSRange {
                var pageRange = NSMakeRange(0, 0)
                switch(self) {
                case .addH1(let string, let backgroundBoxColor):
                    pageRange = pdf.addH1(string, backgroundBoxColor: backgroundBoxColor, calculationOnly: calculationOnly)
                case .addH2(let string, let backgroundBoxColor):
                    pageRange = pdf.addH2(string, backgroundBoxColor: backgroundBoxColor, calculationOnly: calculationOnly)
                case .addH3(let string, let backgroundBoxColor):
                    pageRange = pdf.addH3(string, backgroundBoxColor: backgroundBoxColor, calculationOnly: calculationOnly)
                case .addH4(let string, let backgroundBoxColor):
                    pageRange = pdf.addH4(string, backgroundBoxColor: backgroundBoxColor, calculationOnly: calculationOnly)
                case .addH5(let string, let backgroundBoxColor):
                    pageRange = pdf.addH5(string, backgroundBoxColor: backgroundBoxColor, calculationOnly: calculationOnly)
                case .addH6(let string, let backgroundBoxColor):
                    pageRange = pdf.addH6(string, backgroundBoxColor: backgroundBoxColor, calculationOnly: calculationOnly)
                case .addBodyText(let string, let backgroundBoxColor):
                    pageRange = pdf.addBodyText(string, backgroundBoxColor: backgroundBoxColor, calculationOnly: calculationOnly)
                case .startNewPage:
                    pageRange = pdf.startNewPage(calculationOnly)
                case .addImages(let imagePaths, let imageCaptions, let imagesPerRow, let spacing, let padding):
                    pageRange = pdf.addImages(imagePaths, imageCaptions: imageCaptions, imagesPerRow: imagesPerRow, spacing: spacing, padding: padding, calculationOnly: calculationOnly)
                case .addImagesRow(let imagePaths, let imageCaptions, let columnWidths, let spacing, let padding, let captionBackgroundColor, let imageBackgroundColor):
                    pageRange = pdf.addImagesRow(imagePaths, imageCaptions: imageCaptions, columnWidths: columnWidths, spacing: spacing, padding: padding, captionBackgroundColor: captionBackgroundColor, imageBackgroundColor: imageBackgroundColor, calculationOnly: calculationOnly)
                case .addAttributedStringsToColumns(let columnWidths, let strings, let horizontalPadding, let allowSplitting, let backgroundColor):
                    pageRange = pdf.addAttributedStringsToColumns(columnWidths, strings: strings, horizontalPadding: horizontalPadding, allowSplitting: allowSplitting, backgroundColor: backgroundColor, calculationOnly: calculationOnly)
                case .addView(let view):
                    pageRange = pdf.addView(view, calculationOnly: calculationOnly)
                }
                
                return pageRange
            }
            
            func getTableOfContentsInfo() -> (TextStyle, String?) {
                switch(self) {
                case .addH1(let string, _):
                    return (.h1, string)
                case .addH2(let string, _):
                    return (.h2, string)
                case .addH3(let string, _):
                    return (.h3, string)
                case .addH4(let string, _):
                    return (.h4, string)
                case .addH5(let string, _):
                    return (.h5, string)
                case .addH6(let string, _):
                    return (.h6, string)
                default:
                    return (.bodyText, nil)
                }
            }
            
        }
        
        // MARK: - Document Node
        class DocumentElement {
            var functionCall: FunctionCall
            var pageRange: NSRange
            
            init(functionCall: FunctionCall, pageRange: NSRange) {
                self.functionCall = functionCall
                self.pageRange = pageRange
            }
            
            func executeFunctionCall(_ pdf: PDFWriter, calculationOnly: Bool = true) -> NSRange {
                self.pageRange = self.functionCall.execute(pdf, calculationOnly: calculationOnly)
                return self.pageRange
            }
        }
        
        // MARK: - TableOfContentsNode
        class TableOfContentsElement {
            var attrString: NSAttributedString
            var pageIndex: Int
            
            init(attrString: NSAttributedString, pageIndex: Int) {
                self.attrString = attrString
                self.pageIndex = pageIndex
            }
        }
        
        var document = Array<DocumentElement>()
        var tableOfContents = Array<TableOfContentsElement>()
        var tableOfContentsPagesRange = NSMakeRange(0, 0)
        
        var tableOfContentsOnPage = 1
        var biggestHeadingToIncludeInTOC = TextStyle.h1
        var smallestHeadingToIncludeInTOC = TextStyle.h6
        
        // NOTE: this page only fills in the page numbers as if TOC would never be inserted into the document
        // actual page numbers are calculated within the drawTableOfContentsCall
        func generateTableOfContents() -> Array<TableOfContentsElement> {
            var tableOfContents = Array<TableOfContentsElement>()
            
            var pageIndex = -1
            for i in 0 ..< document.count {
                let docNode = document[i]
                pageIndex += docNode.pageRange.location
                
                let (textStyle, label) = docNode.functionCall.getTableOfContentsInfo()
                
                if let heading = label {
                    if(textStyle.rawValue >= biggestHeadingToIncludeInTOC.rawValue && textStyle.rawValue <= smallestHeadingToIncludeInTOC.rawValue) {
                        // TODO: create a properly formatted string
                        let tocNode = TableOfContentsElement(attrString: NSAttributedString(string: heading), pageIndex: pageIndex)
                        tableOfContents.append(tocNode)
                        //XCGLogger.debug("TOC: \(pageIndex) \(heading)")
                    }
                }
                
                pageIndex += docNode.pageRange.length
            }
            return tableOfContents
        }
        /*
         var pagesCount: Int {
         get {
         if(document.count == 0) {
         XCGLogger.warning("document doesn't have any elements, pagesCount would not be accurate")
         }
         if((tableOfContentsPagesRange.location + tableOfContentsPagesRange.length) == 0) {
         XCGLogger.warning("table of contents not laid out, pagesCount would not be accurate")
         }
         var pagesCount = 0
         for (var i = 0; i < document.count; i++) {
         let docNode = document[i]
         //XCGLogger.debug("\(i) \(docNode.functionCall) \(StringFromRange(docNode.pageRange))")
         pagesCount += (docNode.pageRange.location + docNode.pageRange.length)
         }
         
         pagesCount += (tableOfContentsPagesRange.location + tableOfContentsPagesRange.length)
         
         return pagesCount
         }
         }*/
    }
    
    // MARK: - Text Style
    public enum TextStyle: Int {
        case h1 = 0
        case h2 = 1
        case h3 = 2
        case h4 = 3
        case h5 = 4
        case h6 = 5
        case bodyText = 6
    }
    
    // MARK: - Text Formatter
    public class DefaultTextFormatter {
        func attributedStringForStyle(_ string: String, style: TextStyle) -> NSAttributedString {
            let attrString = NSMutableAttributedString(string: string)
            
            let paragraphStyle = NSMutableParagraphStyle()
            switch(style) {
            case .h1:
                attrString.addAttribute(NSAttributedStringKey.font, value:UIFont.boldSystemFont(ofSize: 24), range: NSMakeRange(0, attrString.length))
                paragraphStyle.alignment = .center
            case .h2:
                attrString.addAttribute(NSAttributedStringKey.font, value:UIFont.boldSystemFont(ofSize: 20), range: NSMakeRange(0, attrString.length))
                paragraphStyle.alignment = .center
            case .h3:
                attrString.addAttribute(NSAttributedStringKey.font, value:UIFont.boldSystemFont(ofSize: 16), range: NSMakeRange(0, attrString.length))
                paragraphStyle.alignment = .center
            case .h4:
                attrString.addAttribute(NSAttributedStringKey.font, value:UIFont.boldSystemFont(ofSize: 14), range: NSMakeRange(0, attrString.length))
            case .h5:
                attrString.addAttribute(NSAttributedStringKey.font, value:UIFont.boldSystemFont(ofSize: 12), range: NSMakeRange(0, attrString.length))
            case .h6:
                attrString.addAttribute(NSAttributedStringKey.font, value:UIFont.boldSystemFont(ofSize: 10), range: NSMakeRange(0, attrString.length))
            case .bodyText:
                attrString.addAttribute(NSAttributedStringKey.font, value:UIFont.systemFont(ofSize: 10), range: NSMakeRange(0, attrString.length))
            }
            
            attrString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            return attrString
        }
        
    }
    
    // MARK: - PDFWriter
    public class PDFWriter {
        var textFormatter: DefaultTextFormatter
        
        var pageSize: PageSize
        var pageOrientation: PageOrientation
        var leftMargin:CGFloat
        var rightMargin: CGFloat
        var topMargin: CGFloat
        var bottomMargin: CGFloat
        
        var currentPage = -1
        var pagesCount = 0
        var currentLocation = CGPoint(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude)
        var availablePageRect = CGRect.zero
        
        var headerFooterTexts: Array<HeaderFooterText>
        var headerFooterImages: Array<HeaderFooterImage>
        
        let kPageNumberPlaceholder: String
        let kPagesCountPlaceholder: String
        let kStandardSpacing: CGFloat
        let kDefaultBackgroundBoxColor: UIColor
        
        init(textFormatter: DefaultTextFormatter, pageSize: PageSize, pageOrientation: PageOrientation, leftMargin: CGFloat, rightMargin: CGFloat,
             topMargin: CGFloat, bottomMargin: CGFloat, pagesCount: Int, headerFooterTexts: Array<HeaderFooterText>,
             headerFooterImages: Array<HeaderFooterImage>, kPageNumberPlaceholder: String, kPagesCountPlaceholder: String,
             kStandardSpacing: CGFloat, kDefaultBackgroundBoxColor: UIColor) {
            self.textFormatter = textFormatter
            self.pageSize = pageSize
            self.pageOrientation = pageOrientation
            self.leftMargin = leftMargin
            self.rightMargin = rightMargin
            self.topMargin = topMargin
            self.bottomMargin = bottomMargin
            
            self.pagesCount = pagesCount
            self.headerFooterImages = headerFooterImages
            self.headerFooterTexts = headerFooterTexts
            
            self.kPageNumberPlaceholder = kPageNumberPlaceholder
            self.kPagesCountPlaceholder = kPagesCountPlaceholder
            self.kStandardSpacing = kStandardSpacing
            self.kDefaultBackgroundBoxColor = kDefaultBackgroundBoxColor
            
            let bounds = getPageBounds()
            let origin = CGPoint(x: bounds.origin.x + leftMargin, y: bounds.origin.y + topMargin)
            let size = CGSize(width: bounds.size.width - (leftMargin + rightMargin),
                              height: bounds.size.height - (topMargin + bottomMargin))
            self.availablePageRect = CGRect(origin: origin, size: size)
        }
        
        var availablePageSize: CGSize {
            get { return availablePageRect.size }
        }
        
        func openPDF(_ path: String, title: String?,  author: String?) -> NSError? {
            let pageRect = getPageBounds()
            
            var documentInfo = [kCGPDFContextCreator as String: "\(SimplePDFUtilities.getApplicationName()) \(SimplePDFUtilities.getApplicationVersion())"]
            if let a = author {
                documentInfo[kCGPDFContextAuthor as String] = a
            }
            if let t = title {
                documentInfo[kCGPDFContextTitle as String] = t
            }
            
            UIGraphicsBeginPDFContextToFile(path, pageRect, documentInfo)
            
            //currentLocation.y = CGFloat.max
            //startNewPage()
            return nil
        }
        
        
        func closePDF() {
            UIGraphicsEndPDFContext()
        }
        
        func startNewPage(_ calculationOnly: Bool = false) -> NSRange {
            if(calculationOnly == false) {
                UIGraphicsBeginPDFPage()
            }
            currentPage += 1
            currentLocation = CGPoint.zero
            if(calculationOnly == false) {
                addPageHeaderFooter()
            }
            
            return NSMakeRange(1, 0)
        }
        
        // MARK: Headers and Footers
        func addPageHeaderFooter() {
            /*if(pagesCount == 0) {
             XCGLogger.warning("pages count not assigned, if it's printed in a header/footer, it would be wrong.")
             }*/
            // draw top line
            drawLine(CGPoint(x: availablePageRect.origin.x, y: availablePageRect.origin.y-10),
                     p2: CGPoint(x: availablePageRect.origin.x + availablePageRect.size.width, y: availablePageRect.origin.y - 10),
                     color: nil)
            // draw bottom line
            drawLine(CGPoint(x: availablePageRect.origin.x, y: availablePageRect.origin.y + availablePageRect.size.height + 1),
                     p2: CGPoint(x: availablePageRect.origin.x + availablePageRect.size.width, y: availablePageRect.origin.y + availablePageRect.size.height + 1),
                     color: nil)
            
            for i in 0 ..< self.headerFooterTexts.count {
                var text = self.headerFooterTexts[i]
                let textString = NSMutableAttributedString(attributedString: text.attributedString)
                textString.mutableString.replaceOccurrences(of: kPageNumberPlaceholder, with: "\(currentPage + 1)", options: [], range: NSMakeRange(0, textString.length))
                textString.mutableString.replaceOccurrences(of: kPagesCountPlaceholder, with: "\(pagesCount)", options: [], range: NSMakeRange(0, textString.length))
                text.attributedString = textString
                if NSLocationInRange(currentPage, text.pageRange) {
                    switch(text.type) {
                    case .header:
                        addHeaderText(text)
                    case .footer:
                        addFooterText(text)
                    }
                }
            }
            
            for i in 0 ..< self.headerFooterImages.count {
                let image = self.headerFooterImages[i]
                if(image.imagePath.isEmpty && image.image == nil) {
                    print("ERROR: image path is empty and image is null, skipping")
                    continue
                }
                if NSLocationInRange(currentPage, image.pageRange) {
                    switch(image.type) {
                    case .header:
                        addHeaderImage(image)
                    case .footer:
                        addFooterImage(image)
                    }
                }
            }
        }
        
        func addHeaderText(_ header: HeaderFooterText) {
            let availableHeight = topMargin - 11
            let framesetter = CTFramesetterCreateWithAttributedString(header.attributedString)
            var suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSize(width: availablePageRect.width, height: CGFloat.greatestFiniteMagnitude), nil)
            if(suggestedSize.height > availableHeight) {
                suggestedSize.height = availableHeight
            }
            
            let textRect = CGRect(x: availablePageRect.origin.x, y: availableHeight - suggestedSize.height, width: availablePageRect.width, height: suggestedSize.height)
            
            drawHeaderFooterText(framesetter, textRect: textRect)
        }
        
        func addFooterText(_ footer: HeaderFooterText) {
            let availableHeight = bottomMargin - 2
            let framesetter = CTFramesetterCreateWithAttributedString(footer.attributedString)
            var suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSize(width: availablePageRect.width, height: CGFloat.greatestFiniteMagnitude), nil)
            if(suggestedSize.height > availableHeight) {
                suggestedSize.height = availableHeight
            }
            
            let textRect = CGRect(x: availablePageRect.origin.x, y: availablePageRect.origin.y + availablePageRect.size.height + 2, width: availablePageRect.width, height: suggestedSize.height)
            
            drawHeaderFooterText(framesetter, textRect: textRect)
            
        }
        
        func drawHeaderFooterText(_ framesetter: CTFramesetter, textRect: CGRect) {
            let textRect2 = convertRectToCoreTextCoordinates(textRect)
            
            let context = UIGraphicsGetCurrentContext()
            let bounds = getPageBounds()
            context!.textMatrix = CGAffineTransform.identity
            context?.translateBy(x: 0, y: bounds.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            
            
            let textPath = CGMutablePath()
            textPath.addRect(textRect2, transform: CGAffineTransform(translationX: 0, y: 0))
            let frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), textPath, nil)
            
            CTFrameDraw(frameRef, context!)
            
            // flip it back
            context?.scaleBy(x: 1.0, y: -1.0)
            context?.translateBy(x: 0, y: -bounds.size.height)
        }
        
        func addHeaderImage(_ header: HeaderFooterImage) {
            let availableHeight = topMargin - 11
            var imageHeight = header.imageHeight
            if(imageHeight > availableHeight) {
                imageHeight = availableHeight
            }
            var image = header.image
            if(image == nil) {
                image = UIImage(contentsOfFile: header.imagePath)
                if(image == nil) {
                    print("ERROR: Unable to read image: \(header.imagePath)")
                    return
                }
            }
            
            let y = availableHeight - imageHeight
            drawHeaderFooterImage(header.alignment, image: image!, imageHeight: imageHeight, y: y)
        }
        
        func addFooterImage(_ footer: HeaderFooterImage) {
            let availableHeight = bottomMargin - 2
            var imageHeight = footer.imageHeight
            if(imageHeight > availableHeight) {
                imageHeight = availableHeight
            }
            var image = footer.image
            if(image == nil) {
                image = UIImage(contentsOfFile: footer.imagePath)
                if(image == nil) {
                    print("ERROR: Unable to read image: \(footer.imagePath)")
                    return
                }
            }
            let y = availablePageRect.origin.y + availablePageRect.size.height + 2
            drawHeaderFooterImage(footer.alignment, image: image!, imageHeight: imageHeight, y: y)
        }
        
        func drawHeaderFooterImage(_ alignment: NSTextAlignment, image: UIImage, imageHeight: CGFloat, y: CGFloat) {
            var x:CGFloat = 0
            let imageWidth = aspectFitWidthForHeight(image.size, height: imageHeight)
            switch(alignment) {
            case .left:
                x = availablePageRect.origin.x
                break;
            case .center:
                x = availablePageRect.origin.x + ((availablePageRect.size.width - imageWidth) / 2)
                break;
            default: // align right
                x = (availablePageRect.origin.x + availablePageRect.size.width) - imageWidth
                break;
            }
            
            let imageRect = CGRect(x: x, y: y, width: imageWidth, height: imageHeight)
            image.draw(in: imageRect)
        }
        
        // MARK: - Document elements
        func addH1(_ string: String, backgroundBoxColor: UIColor?, calculationOnly: Bool = false) -> NSRange {
            let attrString = textFormatter.attributedStringForStyle(string, style: .h1)
            var bbcolor = backgroundBoxColor
            if bbcolor == nil {
                bbcolor = kDefaultBackgroundBoxColor
            }
            return addAttributedString(attrString, allowSplitting: false, backgroundBoxColor: bbcolor, calculationOnly: calculationOnly)
        }
        
        func addH2(_ string: String, backgroundBoxColor: UIColor?, calculationOnly: Bool = false) -> NSRange {
            let attrString = textFormatter.attributedStringForStyle(string, style: .h2)
            var bbcolor = backgroundBoxColor
            if bbcolor == nil {
                bbcolor = kDefaultBackgroundBoxColor
            }
            return addAttributedString(attrString, allowSplitting: false, backgroundBoxColor: bbcolor, calculationOnly: calculationOnly)
        }
        
        func addH3(_ string: String, backgroundBoxColor: UIColor?, calculationOnly: Bool = false) -> NSRange {
            let attrString = textFormatter.attributedStringForStyle(string, style: .h3)
            var bbcolor = backgroundBoxColor
            if bbcolor == nil {
                bbcolor = kDefaultBackgroundBoxColor
            }
            return addAttributedString(attrString, allowSplitting: false, backgroundBoxColor: bbcolor, calculationOnly: calculationOnly)
        }
        func addH4(_ string: String, backgroundBoxColor: UIColor? = nil, calculationOnly: Bool = false) -> NSRange {
            let attrString = textFormatter.attributedStringForStyle(string, style: .h4)
            return addAttributedString(attrString, allowSplitting: false, backgroundBoxColor: backgroundBoxColor, calculationOnly: calculationOnly)
        }
        func addH5(_ string: String, backgroundBoxColor: UIColor? = nil, calculationOnly: Bool = false) -> NSRange {
            let attrString = textFormatter.attributedStringForStyle(string, style: .h5)
            return addAttributedString(attrString, allowSplitting: false, backgroundBoxColor: backgroundBoxColor, calculationOnly: calculationOnly)
        }
        
        func addH6(_ string: String, backgroundBoxColor: UIColor? = nil, calculationOnly: Bool = false) -> NSRange {
            let attrString = textFormatter.attributedStringForStyle(string, style: .h6)
            return addAttributedString(attrString, allowSplitting: false, backgroundBoxColor: backgroundBoxColor, calculationOnly: calculationOnly)
        }
        func addBodyText(_ string: String, backgroundBoxColor: UIColor? = nil, calculationOnly: Bool = false) -> NSRange {
            let attrString = textFormatter.attributedStringForStyle(string, style: .bodyText)
            return addAttributedString(attrString, allowSplitting: true, backgroundBoxColor: backgroundBoxColor, calculationOnly: calculationOnly)
            
        }
        
        func addImages(_ imagePaths:[String], imageCaptions: [String], imagesPerRow:Int = 3, spacing:CGFloat = 2, padding:CGFloat = 5, calculationOnly: Bool = false) -> NSRange {
            assert(imagePaths.count == imageCaptions.count, "image paths and image captions don't have same number of elements")
            var imagePathsOk = imagePaths
            var funcCallRange = NSMakeRange(0, 0)
            
            var columnWidths = Array<CGFloat>()
            let singleColumnWidth = availablePageRect.size.width / CGFloat(imagesPerRow)
            for _ in 0 ..< imagesPerRow {
                columnWidths.append(singleColumnWidth)
            }
            
            var attributedImageCaptions = Array<NSAttributedString>()
            for i in 0 ..< imageCaptions.count {
                let mutableCaption = NSMutableAttributedString(attributedString: textFormatter.attributedStringForStyle(imageCaptions[i], style: .h6))
                /* this doesn't work since captions are drawn using CTLine
                 let paragraphStyle = NSMutableParagraphStyle()
                 paragraphStyle.alignment = .Center
                 mutableCaption.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, mutableCaption.length)) */
                attributedImageCaptions.append(mutableCaption)
            }
            
            
            var rowIndex = 0
            repeat {
                var itemsToGet = imagesPerRow
                if(imagePaths.count < itemsToGet){
                    itemsToGet = imagePaths.count
                }
                let rowImages = Array(imagePaths[0..<itemsToGet])
                let rowCaptions = Array(attributedImageCaptions[0..<itemsToGet])
                imagePathsOk[0..<itemsToGet] = []
                attributedImageCaptions[0..<itemsToGet] = []
                
                let thisRange = addImagesRow(rowImages, imageCaptions: rowCaptions, columnWidths: Array(columnWidths[0..<itemsToGet]), spacing: spacing, padding: padding, captionBackgroundColor: kDefaultBackgroundBoxColor, calculationOnly: calculationOnly)
                
                if(rowIndex == 0) {
                    funcCallRange = thisRange
                }
                else {
                    funcCallRange.length += (thisRange.location + thisRange.length)
                }
                rowIndex += 1
                
            } while(imagePathsOk.count > 0)
            return funcCallRange
        }
        
        func addImagesRow(_ imagePaths: [String], imageCaptions: [NSAttributedString], columnWidths: [CGFloat],
                          spacing: CGFloat = 2, padding: CGFloat = 5, captionBackgroundColor: UIColor? = nil,
                          imageBackgroundColor: UIColor? = nil, calculationOnly: Bool = false) -> NSRange {
            assert(imagePaths.count == imageCaptions.count && imageCaptions.count == columnWidths.count,
                   "image paths, image captions and column widths don't have same number of elements")
            
            var funcCallRange = NSMakeRange(0, 0)
            
            var imageProperties = Array<NSDictionary>()
            for i in 0 ..< imagePaths.count {
                if(imagePaths[i].isEmpty) {
                    imageProperties.append(NSDictionary())
                    continue
                }
                let thisImageProperties = SimplePDFUtilities.getImageProperties(imagePaths[i])
                imageProperties.append(thisImageProperties! as NSDictionary)
            }
            
            var maxLineHeight:CGFloat = 0
            for i in 0 ..< imageCaptions.count {
                let thisCaption = imageCaptions[i]
                if(thisCaption.length == 0) {
                    continue
                }
                let line = CTLineCreateWithAttributedString(thisCaption)
                let lineBounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.useGlyphPathBounds)
                
                if(lineBounds.size.height > maxLineHeight) {
                    maxLineHeight = lineBounds.size.height
                }
            }
            
            // start a new page if needed
            for i in 0 ..< imagePaths.count {
                let thisWidth = columnWidths[i] - (2 * padding)
                let availableSpace = CGSize(width: CGFloat.greatestFiniteMagnitude, height: availablePageRect.size.height - currentLocation.y)
                
                let thisProperties = imageProperties[i]
                if thisProperties.allKeys.count == 0 {
                    continue
                }
                let imageWidth = thisProperties[kCGImagePropertyPixelWidth as String] as! CGFloat
                let imageHeight = thisProperties[kCGImagePropertyPixelHeight as String] as! CGFloat
                
                let imageSize = CGSize(width: imageWidth, height:imageHeight)
                
                let fitHeight = self.aspectFitHeightForWidth(imageSize, width: thisWidth)
                if(fitHeight + maxLineHeight > availableSpace.height) {
                    funcCallRange.location = 1
                    _ = startNewPage(calculationOnly)
                    break
                }
            }
            
            currentLocation.y += padding
            var maxHeightRendered: CGFloat = 0
            var loc = currentLocation
            for i in 0 ..< imagePaths.count {
                // render the label
                var currentY = loc.y
                let thisCaption = imageCaptions[i]
                let thisWidth = columnWidths[i]
                var availableSpace = CGSize(width: thisWidth - (2 * padding), height: availablePageRect.size.height - loc.y)
                
                if(thisCaption.length != 0) {
                    let line = CTLineCreateWithAttributedString(thisCaption)
                    let truncationToken = CTLineCreateWithAttributedString( NSAttributedString(string:"…"))
                    let truncatedLine = CTLineCreateTruncatedLine(line, Double(availableSpace.width), CTLineTruncationType.end, truncationToken)
                    
                    if(calculationOnly == false) {
                        if(captionBackgroundColor != nil) {
                            let originalTextRect = CGRect(x: availablePageRect.origin.x + loc.x + padding, y: availablePageRect.origin.y + currentY,
                                                          width: thisWidth - (2 * padding), height: maxLineHeight + spacing)
                            drawRect(originalTextRect, fillColor: captionBackgroundColor)
                        }
                        
                    }
                    let originalPoint = CGPoint(x: availablePageRect.origin.x + loc.x + padding, y: availablePageRect.origin.y + currentY)
                    var textPoint = convertPointToCoreTextCoordinates(originalPoint)
                    
                    // since we need to provide the base line coordinates to CoreText, we should subtract the maxLineHeight
                    textPoint.y -= maxLineHeight
                    
                    if(calculationOnly == false) {
                        // flip context
                        let context = UIGraphicsGetCurrentContext()
                        let bounds = UIGraphicsGetPDFContextBounds()
                        context!.textMatrix = CGAffineTransform.identity
                        context?.translateBy(x: bounds.origin.x, y: bounds.size.height)
                        context?.scaleBy(x: 1.0, y: -1.0)
                        
                        context?.textPosition = CGPoint(x: textPoint.x, y: textPoint.y)
                        CTLineDraw(truncatedLine!, context!)
                        
                        // flip it back
                        context?.scaleBy(x: 1.0, y: -1.0)
                        context?.translateBy(x: -bounds.origin.x, y: -bounds.size.height)
                    }
                }
                
                currentY += (maxLineHeight + spacing)
                availableSpace.height -= (maxLineHeight + spacing)
                
                // render the image
                let thisProperties = imageProperties[i]
                
                if(thisProperties.allKeys.count == 0) {
                    // advance to next column
                    loc.x += thisWidth
                    continue
                }
                
                let imageWidth = thisProperties[kCGImagePropertyPixelWidth as String] as! CGFloat
                let imageHeight = thisProperties[kCGImagePropertyPixelHeight as String] as! CGFloat
                
                let originalImageSize = CGSize(width: imageWidth, height:imageHeight)
                
                let fitHeight = self.aspectFitHeightForWidth(originalImageSize, width: availableSpace.width)
                var imageSizeToRender = CGSize(width: availableSpace.width, height: fitHeight)
                if(fitHeight > availableSpace.height) {
                    let fitWidth = self.aspectFitWidthForHeight(originalImageSize, height: availableSpace.height)
                    imageSizeToRender = CGSize(width: fitWidth, height: availableSpace.height)
                }
                
                if(calculationOnly == false) {
                    if(imageBackgroundColor != nil) {
                        let bgRect = CGRect(x: availablePageRect.origin.x + loc.x + padding, y: availablePageRect.origin.y + currentY,
                                            width: availableSpace.width, height: availableSpace.height)
                        drawRect(bgRect, fillColor: imageBackgroundColor)
                    }
                }
                
                let imageX = availablePageRect.origin.x + loc.x + padding + ((availableSpace.width - imageSizeToRender.width) / 2)
                let imageY = availablePageRect.origin.y + currentY
                let imageRect = CGRect(x: imageX, y: imageY, width: imageSizeToRender.width, height: imageSizeToRender.height)
                
                if(calculationOnly == false) {
                    let image = UIImage(contentsOfFile: imagePaths[i])
                    image?.draw(in: imageRect)
                }
                
                // advance to next column
                loc.x += thisWidth
                
                let totalHeight = (maxLineHeight + imageSizeToRender.height + spacing)
                
                if(totalHeight  > maxHeightRendered) {
                    maxHeightRendered = totalHeight
                }
            }
            currentLocation.y += maxHeightRendered
            currentLocation.y += kStandardSpacing
            return funcCallRange
        }
        
        func addAttributedStringsToColumns(_ columnWidths: [CGFloat], strings: [ NSAttributedString], horizontalPadding: CGFloat = 5, allowSplitting: Bool = true, backgroundColor: UIColor? = nil, calculationOnly: Bool = false) -> NSRange {
            assert(columnWidths.count == strings.count, "columnWidths and strings array don't have same number of elements")
            
            var funcCallRange = NSMakeRange(0, 0)
            
            var ranges = Array<CFRange>() // tracks range for each column
            var framesetters = Array<CTFramesetter>() // tracks framsetter for each column
            for i in 0 ..< strings.count {
                ranges.append(CFRangeMake(0, 0))
                framesetters.append(CTFramesetterCreateWithAttributedString(strings[i]))
            }
            
            var availableSpace = CGSize.zero
            if((availablePageRect.size.height - currentLocation.y) <= 0) {
                funcCallRange.location = 1
                _ = startNewPage(calculationOnly)
            }
            else {
                // decide if we start start a new page
                if(allowSplitting == false) {
                    var allStringsFitOnThisPage = true
                    for i in 0 ..< ranges.count {
                        let thisWidth = columnWidths[i]
                        let thisString = strings[i]
                        
                        availableSpace = CGSize(width: thisWidth - (2 * horizontalPadding), height: availablePageRect.size.height - currentLocation.y)
                        
                        if canFitAttributedString(thisString, size: availableSpace) == false {
                            allStringsFitOnThisPage = false
                            break
                        }
                    }
                    
                    if(allStringsFitOnThisPage == false) {
                        var allStringsFitOnANewPage = true
                        for i in 0 ..< ranges.count {
                            let thisWidth = columnWidths[i]
                            let thisString = strings[i]
                            
                            availableSpace = CGSize(width: thisWidth - (2 * horizontalPadding), height: availablePageRect.size.height)
                            
                            if canFitAttributedString(thisString, size: availableSpace) == false {
                                allStringsFitOnANewPage = false
                                break
                            }
                        }
                        
                        if(allStringsFitOnANewPage) {
                            _ = startNewPage(calculationOnly)
                            funcCallRange.location = 1
                        }
                    }
                }
            }
            
            var done = false
            repeat {
                var loc = currentLocation
                var maxHeightRendered:CGFloat = 0
                
                for i in 0 ..< columnWidths.count {
                    var thisRange = ranges[i]
                    let thisFramesetter = framesetters[i]
                    let thisWidth = columnWidths[i]
                    let thisString = strings[i]
                    // skip the column if it has been rendered completely
                    if(thisRange.location >= thisString.length) {
                        loc.x += thisWidth
                        continue
                    }
                    
                    availableSpace = CGSize(width: thisWidth - (2 * horizontalPadding), height: availablePageRect.size.height - loc.y)
                    // if height is -ve, CTFramesetterSuggestFrameSizeWithConstraints doesn't return an empty fitRange
                    if(availableSpace.height <= 0) {
                        break
                    }
                    var fitRange = CFRangeMake(0, 0)
                    let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(thisFramesetter, thisRange, nil, availableSpace, &fitRange)
                    
                    // draw string
                    var originalTextRect = CGRect(x: availablePageRect.origin.x + loc.x, y: availablePageRect.origin.y + loc.y,
                                                  width: thisWidth, height: availableSpace.height)
                    if(calculationOnly == false) {
                        if(backgroundColor != nil) {
                            let boxRect = CGRect(x: originalTextRect.origin.x, y: originalTextRect.origin.y, width: availableSpace.width, height: suggestedSize.height)
                            drawRect(boxRect, fillColor: backgroundColor)
                        }
                    }
                    
                    originalTextRect.origin.x += horizontalPadding
                    originalTextRect.size.width = availableSpace.width
                    
                    let textRect = convertRectToCoreTextCoordinates(originalTextRect)
                    
                    if(calculationOnly == false) {
                        // flip context
                        let context = UIGraphicsGetCurrentContext()
                        let bounds = UIGraphicsGetPDFContextBounds()
                        context!.textMatrix = CGAffineTransform.identity
                        context?.translateBy(x: bounds.origin.x, y: bounds.size.height)
                        context?.scaleBy(x: 1.0, y: -1.0)
                        
                        let textPath = CGMutablePath()
                        textPath.addRect(textRect, transform: CGAffineTransform(rotationAngle: 0))
                        let frameRef = CTFramesetterCreateFrame(thisFramesetter, thisRange, textPath, nil)
                        
                        CTFrameDraw(frameRef, context!)
                        
                        // flip it back
                        context?.scaleBy(x: 1.0, y: -1.0)
                        context?.translateBy(x: -bounds.origin.x, y: -bounds.size.height)
                    }
                    
                    thisRange.location = thisRange.location + fitRange.length
                    ranges[i] = thisRange
                    
                    // if we couldn't render whole string, that means we have utilised all avialable height
                    if(thisRange.location < thisString.length) {
                        maxHeightRendered = availableSpace.height
                    }
                    else {
                        if(suggestedSize.height >= maxHeightRendered) {
                            maxHeightRendered = suggestedSize.height
                        }
                    }
                    
                    loc.x += thisWidth
                }
                
                var shouldAddNewPage = false
                
                done = true
                for i in 0 ..< ranges.count {
                    let thisRange = ranges[i]
                    let thisString = strings[i]
                    if thisRange.location < thisString.length {
                        done = false
                        shouldAddNewPage = true
                        break
                    }
                }
                
                if(shouldAddNewPage) {
                    _ = startNewPage(calculationOnly)
                    funcCallRange.length = funcCallRange.length + 1
                }
                else {
                    currentLocation.y += maxHeightRendered
                    currentLocation.y += kStandardSpacing
                }
                
            } while (!done)
            return funcCallRange
        }
        
        
        func addAttributedString(_ attrString:  NSAttributedString, allowSplitting:Bool = true, backgroundBoxColor: UIColor? = nil, calculationOnly: Bool = false) -> NSRange {
            return addAttributedStringsToColumns([availablePageRect.size.width], strings: [attrString], horizontalPadding: 0.0, allowSplitting: allowSplitting, backgroundColor: backgroundBoxColor, calculationOnly: calculationOnly)
        }
        
        func addView(_ view: UIView, calculationOnly: Bool = false) -> NSRange {
            // Here's how I work with NSRange in these functions
            // location is startPageOffset
            // length is how many pages are added, so (length + location) = last page index
            
            var range = NSMakeRange(0, 0) // a view is always
            if(currentLocation.y > 0) {
                range.location = 1
                _ = startNewPage(calculationOnly)
            }
            
            if(calculationOnly == false) {
                let context = UIGraphicsGetCurrentContext()
                view.layer.render(in: context!)
            }
            
            // one view per page, set Y to maximum so that next call inserts a page
            currentLocation.y = availablePageSize.height
            return range
        }
        
        func drawTableofContents(_ document:DocumentStructure, calculationOnly:Bool = true) -> NSRange {
            if(document.tableOfContents.count == 0) {
                return NSMakeRange(0, 0)
            }
            
            var funcRange = NSMakeRange(0, 0)
            if(currentLocation.y > 0) {
                funcRange.location = 1
                _ = startNewPage(calculationOnly)
            }
            
            let headingRange = addH3("Table of Contents", backgroundBoxColor: nil, calculationOnly: calculationOnly)
            funcRange.length += (headingRange.location + headingRange.length)
            for i in 0 ..< document.tableOfContents.count {
                let tocNode = document.tableOfContents[i]
                
                // NOTE: on very first call to this function, page numbers would not be correct in table of contents because we don't know
                // how many pages TOC would take. It does not matter however because the very first call would be "calculationOnly" anyway
                var tocAdjustedPageNumber = tocNode.pageIndex
                if(tocNode.pageIndex >= document.tableOfContentsOnPage) {
                    tocAdjustedPageNumber += (document.tableOfContentsPagesRange.location + document.tableOfContentsPagesRange.length)
                }
                
                let pageNumberAttrString = NSMutableAttributedString(string: "\(tocAdjustedPageNumber + 1)")
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .right
                pageNumberAttrString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, pageNumberAttrString.length))
                
                let col2Width:CGFloat = 50
                let col1Width = availablePageSize.width - col2Width
                
                let range = addAttributedStringsToColumns([col1Width, col2Width], strings: [tocNode.attrString, pageNumberAttrString], horizontalPadding: 5, allowSplitting: false, backgroundColor: nil, calculationOnly: calculationOnly)
                
                funcRange.length += (range.location + range.length)
            }
            
            // this is to force a page break before new element
            currentLocation.y = availablePageSize.height
            
            return funcRange
        }
        
        
        // MARK: - Drawing
        func drawRect(_ rect: CGRect, fillColor:UIColor?) {
            var fillColorOk = fillColor
            if fillColorOk == nil {
                fillColorOk = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            }
            let context = UIGraphicsGetCurrentContext()
            context?.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1)
            context?.setFillColor(fillColorOk!.cgColor)
            context?.fill(rect)
            //CGContextStrokeRect(context, rect)
        }
        
        func drawLine(_ p1: CGPoint, p2:CGPoint, color:UIColor?, strokeWidth: CGFloat = 1) {
            var colorOk = color
            if colorOk == nil {
                colorOk = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            }
            let context = UIGraphicsGetCurrentContext()
            context?.setStrokeColor(colorOk!.cgColor);
            context?.setLineWidth(strokeWidth);
            context?.move(to: p1);
            context?.addLine(to: p2);
            context?.drawPath(using: CGPathDrawingMode.stroke);
        }
        
        // MARK: - Utilities
        func canFitAttributedString(_ attrString:  NSAttributedString, size:CGSize) -> Bool {
            // if height is -ve, CTFramesetterSuggestFrameSizeWithConstraints doesn't return an empty fitRange
            if(size.height <= 0) {
                return false
            }
            
            let frameSetter = CTFramesetterCreateWithAttributedString(attrString)
            var fitRangeFullSize = CFRangeMake(0, 0)
            CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), nil, size, &fitRangeFullSize)
            if(fitRangeFullSize.length < attrString.length) {
                return false
            }
            return true
        }
        
        func convertRectToCoreTextCoordinates(_ r:CGRect) -> CGRect {
            var rOk = r
            let bounds = getPageBounds()
            rOk.origin.y = bounds.size.height - (r.size.height + r.origin.y)
            return rOk
        }
        
        func convertPointToCoreTextCoordinates(_ p:CGPoint) -> CGPoint {
            var pOK = p
            let bounds = getPageBounds()
            pOK.y = bounds.size.height - p.y
            return pOK
        }
        
        func aspectFitHeightForWidth(_ size: CGSize, width: CGFloat) -> CGFloat {
            let ratio = size.width / width
            let newHeight = size.height / ratio
            return newHeight
        }
        
        func aspectFitWidthForHeight(_ size: CGSize, height: CGFloat) -> CGFloat {
            let ratio = size.height / height
            let newWidth = size.width / ratio
            return newWidth
        }
        
        func getPageBounds() -> CGRect {
            let size = self.pageSize.asCGSize()
            if(pageOrientation == .portrait) {
                return CGRect(origin: CGPoint.zero, size: size)
            }
            else {
                return CGRect(origin: CGPoint.zero, size: CGSize(width: size.height, height: size.width))
            }
        }
    }
    
    // MARK: - PageSize
    public enum PageSize {
        case letter
        case a4
        case custom(size: CGSize)
        
        func asCGSize() -> CGSize {
            switch(self) {
            case .letter:
                return CGSize(width: 612, height: 792)
            case .a4:
                return CGSize(width: 595, height: 842)
            case .custom(let size):
                return size
            }
        }
    }
    
    // MARK: - PageOrientation
    public enum PageOrientation {
        case portrait
        case landscape
    }
    
    // MARK: - HeaderFooterType
    public enum HeaderFooterType {
        case header
        case footer
    }
    
    // MARK: - HeaderFooterText
    public struct HeaderFooterText {
        var type = HeaderFooterType.header
        var pageRange = NSMakeRange(0, 0)
        var attributedString: NSAttributedString
    }
    
    // MARK: - HeaderFooterImage
    public struct HeaderFooterImage {
        var type = HeaderFooterType.header
        var pageRange = NSMakeRange(0, 0)
        var imagePath = ""
        var image: UIImage?
        var imageHeight: CGFloat
        var alignment =  NSTextAlignment.left
    }
    
    // MARK: - SimplePDF vars
    public var textFormatter: DefaultTextFormatter
    public var pageSize: PageSize
    public var pageOrientation: PageOrientation
    public var leftMargin:CGFloat
    public var rightMargin: CGFloat
    public var topMargin: CGFloat
    public var bottomMargin: CGFloat
    
    public var headerFooterTexts = Array<HeaderFooterText>()
    public var headerFooterImages = Array<HeaderFooterImage>()
    
    public let kPageNumberPlaceholder = "{{PAGE_NUMBER}}"
    public let kPagesCountPlaceholder = "{{PAGES_COUNT}}"
    public let kStandardSpacing:CGFloat = 8
    public let kDefaultBackgroundBoxColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    
    public var availablePageSize: CGSize {
        get { return pdfWriter.availablePageSize }
    }
    
    public var pageIndexToShowTOC: Int {
        get { return document.tableOfContentsOnPage }
        set { document.tableOfContentsOnPage = newValue }
    }
    
    public var biggestHeadingToIncludeInTOC: TextStyle {
        get { return document.biggestHeadingToIncludeInTOC }
        set { document.biggestHeadingToIncludeInTOC = newValue }
    }
    public var smallestHeadingToIncludeInTOC: TextStyle {
        get { return document.smallestHeadingToIncludeInTOC }
        set { document.smallestHeadingToIncludeInTOC = newValue }
    }
    
    var pdfFilePath: String
    var authorName: String
    var pdfTitle: String
    
    var document = DocumentStructure()
    var pdfWriter: PDFWriter
    
    public var currentPage : Int {
        get { return self.pdfWriter.currentPage }
    }
    
    /*
     var pagesCount: Int {
     get { return self.document.pagesCount
     }
     }*/
    
    // MARK: - SimplePDF methods
    init(pdfTitle: String, authorName: String, pageSize: PageSize = .a4, pageOrientation: PageOrientation = .portrait,
         leftMargin:CGFloat = 36, rightMargin:CGFloat = 36, topMargin: CGFloat = 72, bottomMargin: CGFloat = 36, textFormatter: DefaultTextFormatter = DefaultTextFormatter()) {
        
        self.leftMargin = leftMargin
        self.rightMargin = rightMargin
        self.topMargin = topMargin
        self.bottomMargin = bottomMargin
        self.pageSize = pageSize
        self.pageOrientation = pageOrientation
        self.textFormatter = textFormatter
        
        self.authorName = authorName
        self.pdfTitle = pdfTitle
        
        let tmpFilePath = SimplePDFUtilities.pathForTmpFile("SimplePDF.pdf")
        self.pdfFilePath = SimplePDFUtilities.renameFilePathToPreventNameCollissions(tmpFilePath)
        
        self.pdfWriter = PDFWriter(textFormatter: textFormatter, pageSize: pageSize, pageOrientation: pageOrientation,
                                   leftMargin: leftMargin, rightMargin: rightMargin, topMargin: topMargin, bottomMargin: bottomMargin,
                                   pagesCount: 0,
                                   headerFooterTexts: headerFooterTexts, headerFooterImages: headerFooterImages,
                                   kPageNumberPlaceholder: kPageNumberPlaceholder, kPagesCountPlaceholder: kPagesCountPlaceholder,
                                   kStandardSpacing: kStandardSpacing, kDefaultBackgroundBoxColor: kDefaultBackgroundBoxColor)
    }
    
    func initializePDFWriter(_ pagesCount: Int) -> PDFWriter {
        return PDFWriter(textFormatter: textFormatter, pageSize: pageSize, pageOrientation: pageOrientation,
                         leftMargin: leftMargin, rightMargin: rightMargin, topMargin: topMargin, bottomMargin: bottomMargin,
                         pagesCount: pagesCount,
                         headerFooterTexts: headerFooterTexts, headerFooterImages: headerFooterImages,
                         kPageNumberPlaceholder: kPageNumberPlaceholder, kPagesCountPlaceholder: kPagesCountPlaceholder,
                         kStandardSpacing: kStandardSpacing, kDefaultBackgroundBoxColor: kDefaultBackgroundBoxColor)
    }
    
    public func writePDFWithoutTableOfContents() -> String {
        
        /////////// CACULATIONS PASS ///////////
        // Start with a clean slate
        self.pdfWriter = initializePDFWriter(0)
        var pageIndex = -1
        for i in 0 ..< document.document.count {
            let docElement = document.document[i]
            //let pageNumber = pageIndex + docElement.pageRange.location
            _ = docElement.executeFunctionCall(pdfWriter, calculationOnly: true)
            pageIndex += (docElement.pageRange.location + docElement.pageRange.length)
        }
        
        /////////// RENDERING PASS ///////////
        self.pdfWriter = initializePDFWriter(pageIndex+1)
        // 1. create context
        _ = pdfWriter.openPDF(pdfFilePath, title: pdfTitle, author: authorName)
        pageIndex = -1
        
        for i in 0 ..< document.document.count {
            let docElement = document.document[i]
            //let pageNumber = pageIndex + docElement.pageRange.location
            _ = docElement.executeFunctionCall(pdfWriter, calculationOnly: false)
            pageIndex += (docElement.pageRange.location + docElement.pageRange.length)
        }
        
        // 3. end pdf context
        pdfWriter.closePDF()
        return pdfFilePath
    }
    
    
    public func writePDFWithTableOfContents() -> String {
        /////////// CACULATIONS PASS ///////////
        // Start with a clean slate
        self.pdfWriter = initializePDFWriter(0)
        
        // Generate TOC data structure
        // todo: empty toc structure here
        document.tableOfContents = document.generateTableOfContents()
        var tocInserted = false
        var pageIndex = -1
        for i in 0 ..< document.document.count {
            let docElement = document.document[i]
            let pageNumber = pageIndex + docElement.pageRange.location
            // if (location == 1 && pageNumber == document.tableOfContentsOnPage) || (location == 0 && pageNumber > document.tableOfContents) {
            if(pageNumber >= document.tableOfContentsOnPage && tocInserted == false) {
                tocInserted = true
                document.tableOfContentsPagesRange = pdfWriter.drawTableofContents(document, calculationOnly: true)
                pageIndex += (document.tableOfContentsPagesRange.location + document.tableOfContentsPagesRange.length)
            }
            
            _ = docElement.executeFunctionCall(pdfWriter, calculationOnly: true)
            pageIndex += (docElement.pageRange.location + docElement.pageRange.length)
        }
        
        if(tocInserted == false) {
            tocInserted = true
            document.tableOfContentsPagesRange = pdfWriter.drawTableofContents(document, calculationOnly: true)
            pageIndex += (document.tableOfContentsPagesRange.location + document.tableOfContentsPagesRange.length)
        }
        
        /////////// RECALCULATE TOC -- AFTER WE HAVE UPDATED THE PAGE RANGES BY INSERTING TOC ///////
        // todo: fill in toc data structure with page numbers here
        document.tableOfContents = document.generateTableOfContents()
        
        /////////// RENDERING PASS ///////////
        self.pdfWriter = initializePDFWriter(pageIndex+1)
        // 1. create context
        _ = pdfWriter.openPDF(pdfFilePath, title: pdfTitle, author: authorName)
        
        tocInserted = false
        pageIndex = -1
        
        for i in 0 ..< document.document.count {
            let docElement = document.document[i]
            let pageNumber = pageIndex + docElement.pageRange.location
            if(pageNumber >= document.tableOfContentsOnPage && tocInserted == false) {
                tocInserted = true
                document.tableOfContentsPagesRange = pdfWriter.drawTableofContents(document, calculationOnly: false)
                pageIndex += (document.tableOfContentsPagesRange.location + document.tableOfContentsPagesRange.length)
            }
            
            _ = docElement.executeFunctionCall(pdfWriter, calculationOnly: false)
            pageIndex += (docElement.pageRange.location + docElement.pageRange.length)
        }
        if(tocInserted == false) {
            tocInserted = true
            document.tableOfContentsPagesRange = pdfWriter.drawTableofContents(document, calculationOnly: false)
            pageIndex += (document.tableOfContentsPagesRange.location + document.tableOfContentsPagesRange.length)
        }
        
        // 3. end pdf context
        pdfWriter.closePDF()
        return pdfFilePath
    }
    
    // MARK: - Commands
    // NOTE: these functions should only be called by consumers of the class, don't call them internally because they change
    // the document structure
    public func startNewPage() -> NSRange {
        let range = pdfWriter.startNewPage(true)
        let funcCall = DocumentStructure.FunctionCall.startNewPage
        let docNode = DocumentStructure.DocumentElement(functionCall: funcCall, pageRange: range)
        document.document.append(docNode)
        return range
    }
    
    public func addH1(_ string: String, backgroundBoxColor: UIColor? = nil) -> NSRange {
        let range = pdfWriter.addH1(string, backgroundBoxColor: backgroundBoxColor, calculationOnly: true)
        let funcCall = DocumentStructure.FunctionCall.addH1(string: string, backgroundBoxColor: backgroundBoxColor)
        let docNode = DocumentStructure.DocumentElement(functionCall: funcCall, pageRange: range)
        document.document.append(docNode)
        return range
    }
    
    public func addH2(_ string: String, backgroundBoxColor: UIColor? = nil) -> NSRange {
        let range = pdfWriter.addH2(string, backgroundBoxColor: backgroundBoxColor, calculationOnly: true)
        let funcCall = DocumentStructure.FunctionCall.addH2(string: string, backgroundBoxColor: backgroundBoxColor)
        let docNode = DocumentStructure.DocumentElement(functionCall: funcCall, pageRange: range)
        document.document.append(docNode)
        return range
    }
    
    public func addH3(_ string: String, backgroundBoxColor: UIColor? = nil) -> NSRange {
        let range = pdfWriter.addH3(string, backgroundBoxColor: backgroundBoxColor, calculationOnly: true)
        let funcCall = DocumentStructure.FunctionCall.addH3(string: string, backgroundBoxColor: backgroundBoxColor)
        let docNode = DocumentStructure.DocumentElement(functionCall: funcCall, pageRange: range)
        document.document.append(docNode)
        return range
    }
    
    public func addH4(_ string: String, backgroundBoxColor: UIColor? = nil) -> NSRange {
        let range = pdfWriter.addH4(string, backgroundBoxColor: backgroundBoxColor, calculationOnly: true)
        let funcCall = DocumentStructure.FunctionCall.addH4(string: string, backgroundBoxColor: backgroundBoxColor)
        let docNode = DocumentStructure.DocumentElement(functionCall: funcCall, pageRange: range)
        document.document.append(docNode)
        return range
    }
    
    public func addH5(_ string: String, backgroundBoxColor: UIColor? = nil) -> NSRange {
        let range = pdfWriter.addH5(string, backgroundBoxColor: backgroundBoxColor, calculationOnly: true)
        let funcCall = DocumentStructure.FunctionCall.addH5(string: string, backgroundBoxColor: backgroundBoxColor)
        let docNode = DocumentStructure.DocumentElement(functionCall: funcCall, pageRange: range)
        document.document.append(docNode)
        return range
    }
    
    public func addH6(_ string: String, backgroundBoxColor: UIColor? = nil) -> NSRange {
        let range = pdfWriter.addH6(string, backgroundBoxColor: backgroundBoxColor, calculationOnly: true)
        let funcCall = DocumentStructure.FunctionCall.addH6(string: string, backgroundBoxColor: backgroundBoxColor)
        let docNode = DocumentStructure.DocumentElement(functionCall: funcCall, pageRange: range)
        document.document.append(docNode)
        return range
    }
    
    public func addBodyText(_ string: String, backgroundBoxColor: UIColor? = nil) -> NSRange {
        let range = pdfWriter.addBodyText(string, backgroundBoxColor: backgroundBoxColor, calculationOnly: true)
        let funcCall = DocumentStructure.FunctionCall.addBodyText(string: string, backgroundBoxColor: backgroundBoxColor)
        let docNode = DocumentStructure.DocumentElement(functionCall: funcCall, pageRange: range)
        document.document.append(docNode)
        return range
    }
    
    public func addImages(_ imagePaths:[String], imageCaptions: [String], imagesPerRow:Int = 3, spacing:CGFloat = 2, padding:CGFloat = 5) -> NSRange {
        let range = pdfWriter.addImages(imagePaths, imageCaptions: imageCaptions, imagesPerRow: imagesPerRow, spacing: spacing, padding: padding, calculationOnly: true)
        let funcCall = DocumentStructure.FunctionCall.addImages(imagePaths: imagePaths, imageCaptions: imageCaptions, imagesPerRow: imagesPerRow, spacing: spacing, padding: padding)
        let docNode = DocumentStructure.DocumentElement(functionCall: funcCall, pageRange: range)
        document.document.append(docNode)
        return range
    }
    
    public func addImagesRow(_ imagePaths: [String], imageCaptions: [ NSAttributedString], columnWidths: [CGFloat],
                             spacing: CGFloat = 2, padding: CGFloat = 5, captionBackgroundColor: UIColor? = nil, imageBackgroundColor: UIColor? = nil) -> NSRange {
        let range = pdfWriter.addImagesRow(imagePaths, imageCaptions: imageCaptions, columnWidths: columnWidths, spacing: spacing, padding: padding, captionBackgroundColor: captionBackgroundColor, imageBackgroundColor: imageBackgroundColor, calculationOnly: true)
        let funcCall = DocumentStructure.FunctionCall.addImagesRow(imagePaths: imagePaths, imageCaptions: imageCaptions, columnWidths: columnWidths, spacing: spacing, padding: padding, captionBackgroundColor: captionBackgroundColor, imageBackgroundColor: imageBackgroundColor)
        let docNode = DocumentStructure.DocumentElement(functionCall: funcCall, pageRange: range)
        self.document.document.append(docNode)
        return range
    }
    
    public func addAttributedStringsToColumns(_ columnWidths: [CGFloat], strings: [ NSAttributedString], horizontalPadding: CGFloat = 5, allowSplitting: Bool = true, backgroundColor: UIColor? = nil) -> NSRange  {
        let range = pdfWriter.addAttributedStringsToColumns(columnWidths, strings: strings, horizontalPadding: horizontalPadding, allowSplitting: allowSplitting, backgroundColor: backgroundColor, calculationOnly: true)
        let funcCall = DocumentStructure.FunctionCall.addAttributedStringsToColumns(columnWidths: columnWidths, strings: strings, horizontalPadding: horizontalPadding, allowSplitting: allowSplitting, backgroundColor: backgroundColor)
        let docNode = DocumentStructure.DocumentElement(functionCall: funcCall, pageRange: range)
        self.document.document.append(docNode)
        return range
    }
    
    public func addAttributedString(_ attrString:  NSAttributedString, allowSplitting:Bool = true, backgroundBoxColor: UIColor? = nil) -> NSRange {
        return addAttributedStringsToColumns([pdfWriter.availablePageRect.size.width], strings: [attrString], horizontalPadding: 0.0, allowSplitting: allowSplitting, backgroundColor: backgroundBoxColor)
    }
    
    // This function can be used to render a view to a PDF page (mostly useful to design cover pages). A view is always added to its own page. It starts
    // a new page if required, and any contented added after it appears on the next page.
    //
    // Here's how you can design a cover page with using a UIView (sample applies to any other view that you want to add to pdf)
    // 1. Create a nib with the same dimensions as PDF page (e.g. A4 page is 595x842)
    // 2. All the labels in the view should have their class set to `SimplePDFLabel` (or a subclass of it)
    // 3. Load the view from the nib and add it to pdf
    // ```
    // // ...
    // let coverPage = NSBundle.mainBundle().loadNibNamed("PDFCoverPage", owner: self, options: nil).first as PDFCoverPage
    // pdf.addView(coverPage)
    // ```
    //
    // NOTE:
    //      Please note that if you use the above method to render a view to PDF, AutoLayout will *not* be run on it, If your view doesn't rely on
    // autolayout e.g. say it's a table, may be an invoice?, you don't need to worry about anything.
    //
    // However, if your view uses AutoLayout to correctly position elements, you *have to* add it to the active view hierarchy. You can add to the
    // view hierarchy off-screen, then call `pdf.addView()` to render it to PDF. The catch here is that now the view would render as *bitmap*. This means
    // any labels will not be selectable as text and they would lose quality if you zoom in (because they are bitmaps).
    //
    
    public func addView(_ view: UIView) -> NSRange {
        let range = pdfWriter.addView(view, calculationOnly: true)
        let funcCall = DocumentStructure.FunctionCall.addView(view: view)
        let documentNode = DocumentStructure.DocumentElement(functionCall: funcCall, pageRange: range)
        self.document.document.append(documentNode)
        return range
    }
}
