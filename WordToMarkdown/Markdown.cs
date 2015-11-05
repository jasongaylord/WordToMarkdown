using System;
using System.IO.Compression;
using System.IO;
using System.Xml;
using System.Xml.Xsl;
using System.Reflection;

namespace WordToMakdown
{
    public class Markdoown
    {
        public string FromWord(string docx)
        {
            // Extract the DOCX to a temporary directory
            ZipArchive ziparchive;
            try
            {
                ziparchive = ZipFile.Open(docx, ZipArchiveMode.Read);
            }
            catch
            {
                throw new Exception("The file '" + docx + "' cannot be found or is corrupt.");
            }

            // Read the common entries into streams
            Stream sdocument;
            Stream srdocument;
            Stream score;
            try
            {
                sdocument = ziparchive.GetEntry(@"word/document.xml").Open();
                srdocument = ziparchive.GetEntry(@"word/_rels/document.xml.rels").Open();
                score = ziparchive.GetEntry(@"docProps/core.xml").Open();
            }
            catch
            {
                throw new Exception("The file '" + docx + "' appears to be corrupt.");
            }

            // Convert the sdocument and srdocument to MemoryStream Objects
            var mdoc = new MemoryStream();
            var mrel = new MemoryStream();
            try
            {
                sdocument.CopyTo(mdoc);
                srdocument.CopyTo(mrel);
                // TODO: Strip the Xml Header so the Rels can be imported?
                //srdocument.CopyTo(combined);
            }
            catch
            {
                throw new Exception("The file '" + docx + "' appears to be corrupt or the contents cannot be read.");
            }

            // XML document converstion/translation to Intermediate (Simple) format
            Stream xslDoc;
            var doc = new XmlDocument();
            var rels = new XmlDocument();
            var xsl = new XslCompiledTransform();
            var writer = new StringWriter();
            try
            {
                // Load XSLT from solution
                xslDoc = Assembly.GetExecutingAssembly().GetManifestResourceStream("WordToMarkdown.WordToSimple.xslt");
                var reader = XmlReader.Create(xslDoc);
                xsl.Load(reader);

                // Load the XML
                mdoc.Position = 0;
                doc.Load(mdoc);

                // Load the Rels XML
                mrel.Position = 0;
                rels.Load(mrel);

                // Loop adding in the XML
                foreach (XmlNode node in rels.DocumentElement) //.ChildNodes)
                {
                    var imported = doc.ImportNode(node, true);
                    doc.DocumentElement.AppendChild(imported);
                }

                // Transform into String Writer
                xsl.Transform(doc.CreateNavigator(), null, writer);
            }
            catch (Exception ex)
            {
                throw new Exception("The Word file could not be transformed to the intermediate format as it may be corrupt.");
            }

            // TODO: Remove unwanted whitespace (if it exists) in the tags
            // Obtain simple output
            var simple = writer.ToString();

            Stream xslDoc2;
            var doc2 = new XmlDocument();
            var xsl2 = new XslCompiledTransform();
            var writer2 = new StringWriter();
            try
            {
                // Load XSLT from solution
                xslDoc2 = Assembly.GetExecutingAssembly().GetManifestResourceStream("WordToMarkdown.SimpleToMarkdown.xslt");
                var reader2 = XmlReader.Create(xslDoc2);
                xsl2.Load(reader2);

                // Load the XML
                var sreader = new StringReader(simple);
                doc2.Load(sreader);

                // Transform into String Writer
                xsl2.Transform(doc2.CreateNavigator(), null, writer2);
            }
            catch (Exception ex)
            {
                throw new Exception("The intermediate format could not be transformed to Markdown. The Word file may be corrupt.");
            }

            return writer2.ToString();
        }
    }
}