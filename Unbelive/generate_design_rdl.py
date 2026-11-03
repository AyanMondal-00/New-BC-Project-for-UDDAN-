


# -*- coding: utf-8 -*-
with open('qr_code_b64.txt', 'r', encoding='utf-8') as qf:
    qr_b64 = qf.read().strip()

rdl_content = f'''<?xml version="1.0" encoding="utf-8"?>
<Report xmlns="http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition" xmlns:rd="http://schemas.microsoft.com/SQLServer/reporting/reportdesigner">
  <AutoRefresh>0</AutoRefresh>
  <DataSources>
    <DataSource Name="DataSource">
      <ConnectionProperties>
        <DataProvider>SQL</DataProvider>
        <ConnectString />
      </ConnectionProperties>
      <rd:SecurityType>None</rd:SecurityType>
    </DataSource>
  </DataSources>
  <DataSets>
    <DataSet Name="DataSet_Result">
      <Query>
        <DataSourceName>DataSource</DataSourceName>
        <CommandText />
      </Query>
      <Fields>
        <Field Name="Dummy"><DataField>Dummy</DataField></Field>
      </Fields>
    </DataSet>
  </DataSets>
  <ReportSections>
    <ReportSection>
      <Body>
        <Height>29.7cm</Height>
        <ReportItems>
          <!-- Top Accent Bar: Blue 16.37cm + Coral 4.63cm = 21.0cm -->
          <Textbox Name="TopAccentBlue">
            <Paragraphs><Paragraph><TextRuns><TextRun><Value /></TextRun></TextRuns></Paragraph></Paragraphs>
            <Top>0cm</Top><Left>0cm</Left><Height>0.21cm</Height><Width>16.37cm</Width>
            <Style><BackgroundColor>#1A74BA</BackgroundColor><Border><Style>None</Style></Border></Style>
          </Textbox>
          <Textbox Name="TopAccentCoral">
            <Paragraphs><Paragraph><TextRuns><TextRun><Value /></TextRun></TextRuns></Paragraph></Paragraphs>
            <Top>0cm</Top><Left>16.37cm</Left><Height>0.21cm</Height><Width>4.63cm</Width>
            <Style><BackgroundColor>#F2666E</BackgroundColor><Border><Style>None</Style></Border></Style>
          </Textbox>

          <!-- Header Logo AIRiQ -->
          <Textbox Name="LogoAIR">
            <Paragraphs>
              <Paragraph>
                <TextRuns>
                  <TextRun>
                    <Value>AIR</Value>
                    <Style><FontFamily>Segoe UI</FontFamily><FontSize>25pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style>
                  </TextRun>
                  <TextRun>
                    <Value>iQ</Value>
                    <Style><FontFamily>Segoe UI</FontFamily><FontSize>25pt</FontSize><FontWeight>Bold</FontWeight><Color>#F2666E</Color></Style>
                  </TextRun>
                </TextRuns>
              </Paragraph>
            </Paragraphs>
            <Top>0.9cm</Top><Left>1.41cm</Left><Height>1.1cm</Height><Width>6cm</Width>
            <Style><PaddingLeft>0pt</PaddingLeft><PaddingTop>0pt</PaddingTop><Border><Style>None</Style></Border></Style>
          </Textbox>

          <Textbox Name="LogoSubtitle">
            <Paragraphs>
              <Paragraph>
                <TextRuns>
                  <TextRun>
                    <Value>T R A V E L   P L A T F O R M</Value>
                    <Style><FontFamily>Segoe UI</FontFamily><FontSize>5.8pt</FontSize><FontWeight>Bold</FontWeight><Color>#6B7A90</Color></Style>
                  </TextRun>
                </TextRuns>
              </Paragraph>
            </Paragraphs>
            <Top>2.0cm</Top><Left>1.41cm</Left><Height>0.4cm</Height><Width>6cm</Width>
            <Style><PaddingLeft>0pt</PaddingLeft><PaddingTop>0pt</PaddingTop><Border><Style>None</Style></Border></Style>
          </Textbox>

          <!-- Top Right TAX INVOICE -->
          <Textbox Name="TitleTaxInvoice">
            <Paragraphs>
              <Paragraph>
                <TextRuns>
                  <TextRun>
                    <Value>TAX INVOICE</Value>
                    <Style><FontFamily>Segoe UI</FontFamily><FontSize>19pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style>
                  </TextRun>
                </TextRuns>
                <Style><TextAlign>Right</TextAlign></Style>
              </Paragraph>
            </Paragraphs>
            <Top>0.9cm</Top><Left>13.0cm</Left><Height>0.9cm</Height><Width>6.59cm</Width>
            <Style><PaddingRight>0pt</PaddingRight><PaddingTop>0pt</PaddingTop><Border><Style>None</Style></Border></Style>
          </Textbox>

          <Textbox Name="TitleSampleSub">
            <Paragraphs>
              <Paragraph>
                <TextRuns>
                  <TextRun>
                    <Value>e-Invoice  ·  SAMPLE — NOT VALID FOR GST</Value>
                    <Style><FontFamily>Segoe UI</FontFamily><FontSize>6.4pt</FontSize><FontWeight>Bold</FontWeight><Color>#F2666E</Color></Style>
                  </TextRun>
                </TextRuns>
                <Style><TextAlign>Right</TextAlign></Style>
              </Paragraph>
            </Paragraphs>
            <Top>1.95cm</Top><Left>11.0cm</Left><Height>0.45cm</Height><Width>8.59cm</Width>
            <Style><PaddingRight>0pt</PaddingRight><PaddingTop>0pt</PaddingTop><Border><Style>None</Style></Border></Style>
          </Textbox>

          <!-- ================= 1. E-INVOICE DETAILS BOX ================= -->
          <Rectangle Name="BoxEInvoice">
            <Top>2.6cm</Top><Left>1.41cm</Left><Height>2.33cm</Height><Width>18.18cm</Width>
            <Style>
              <BackgroundColor>#F6F9FC</BackgroundColor>
              <Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.8pt</Width></Border>
            </Style>
            <ReportItems>
              <!-- Blue indicator tag -->
              <Textbox Name="TagEInvoice">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value /></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.28cm</Top><Left>0.42cm</Left><Height>0.4cm</Height><Width>0.09cm</Width>
                <Style><BackgroundColor>#1A74BA</BackgroundColor><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="LblEInvoiceDetails">
                <Paragraphs>
                  <Paragraph>
                    <TextRuns>
                      <TextRun>
                        <Value>E-INVOICE DETAILS</Value>
                        <Style><FontFamily>Segoe UI</FontFamily><FontSize>6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style>
                      </TextRun>
                    </TextRuns>
                  </Paragraph>
                </Paragraphs>
                <Top>0.25cm</Top><Left>0.62cm</Left><Height>0.45cm</Height><Width>8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>

              <!-- IRN Row -->
              <Textbox Name="LblIRN">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>IRN</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.72cm</Top><Left>0.42cm</Left><Height>0.42cm</Height><Width>2.4cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="ValIRN">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>4a43161a3dbc2682656c1c9eb39f075414dbb65b77deec861125428762493db2</Value><Style><FontFamily>Consolas</FontFamily><FontSize>6.8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.72cm</Top><Left>2.85cm</Left><Height>0.42cm</Height><Width>12.8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>

              <!-- Ack No Row -->
              <Textbox Name="LblAckNo">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>Ack No.</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>1.12cm</Top><Left>0.42cm</Left><Height>0.38cm</Height><Width>2.4cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="ValAckNo">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>112610000000001</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>1.12cm</Top><Left>2.85cm</Left><Height>0.38cm</Height><Width>8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>

              <!-- Ack Date Row -->
              <Textbox Name="LblAckDate">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>Ack Date</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>1.47cm</Top><Left>0.42cm</Left><Height>0.38cm</Height><Width>2.4cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="ValAckDate">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>08 Sep 2026 11:42</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>1.47cm</Top><Left>2.85cm</Left><Height>0.38cm</Height><Width>8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>

              <!-- e-Invoice status Row -->
              <Textbox Name="LblStatus">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>e-Invoice status</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>1.82cm</Top><Left>0.42cm</Left><Height>0.38cm</Height><Width>2.4cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="ValStatus">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>Generated</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>1.82cm</Top><Left>2.85cm</Left><Height>0.38cm</Height><Width>8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>

              <!-- QR Code & Signed QR Code Label -->
              <Image Name="ImgQRCode">
                <Source>Embedded</Source>
                <Value>QRCodeImage</Value>
                <Sizing>FitProportional</Sizing>
                <Top>0.22cm</Top><Left>16.0cm</Left><Height>1.65cm</Height><Width>1.65cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Image>
              <Textbox Name="LblSignedQR">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>Signed QR Code</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns><Style><TextAlign>Center</TextAlign></Style></Paragraph></Paragraphs>
                <Top>1.9cm</Top><Left>15.75cm</Left><Height>0.35cm</Height><Width>2.15cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
            </ReportItems>
          </Rectangle>

          <!-- ================= 2. FOUR META BOXES ================= -->
          <!-- Box Left: INVOICE NO. & REF NO. (Light Blue Fill #EAF3FA) -->
          <Rectangle Name="BoxMetaLeft">
            <Top>5.15cm</Top><Left>1.41cm</Left><Height>1.35cm</Height><Width>8.93cm</Width>
            <Style>
              <BackgroundColor>#EAF3FA</BackgroundColor>
              <Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.8pt</Width></Border>
            </Style>
            <ReportItems>
              <!-- Invoice No column -->
              <Textbox Name="LblInvNo">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>INVOICE NO.</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.18cm</Top><Left>0.42cm</Left><Height>0.35cm</Height><Width>3.8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="ValInvNo">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>103002</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>10.5pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.55cm</Top><Left>0.42cm</Left><Height>0.65cm</Height><Width>3.8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>

              <!-- Vertical Divider -->
              <Textbox Name="DivMetaLeft">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value /></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.2cm</Top><Left>4.46cm</Left><Height>0.95cm</Height><Width>0.03cm</Width>
                <Style><BackgroundColor>#DCE6F0</BackgroundColor><Border><Style>None</Style></Border></Style>
              </Textbox>

              <!-- Ref No column -->
              <Textbox Name="LblRefNo">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>REF NO.</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.18cm</Top><Left>4.88cm</Left><Height>0.35cm</Height><Width>3.8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="ValRefNo">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>—</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>10.5pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.55cm</Top><Left>4.88cm</Left><Height>0.65cm</Height><Width>3.8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
            </ReportItems>
          </Rectangle>

          <!-- Box Right: INVOICE DATE & PLACE OF SUPPLY (White Fill #FFFFFF) -->
          <Rectangle Name="BoxMetaRight">
            <Top>5.15cm</Top><Left>10.66cm</Left><Height>1.35cm</Height><Width>8.93cm</Width>
            <Style>
              <BackgroundColor>#FFFFFF</BackgroundColor>
              <Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.8pt</Width></Border>
            </Style>
            <ReportItems>
              <!-- Invoice Date column -->
              <Textbox Name="LblInvDate">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>INVOICE DATE</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.18cm</Top><Left>0.42cm</Left><Height>0.35cm</Height><Width>3.8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="ValInvDate">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>08 Sep 2026</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>10.5pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.55cm</Top><Left>0.42cm</Left><Height>0.65cm</Height><Width>3.8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>

              <!-- Vertical Divider -->
              <Textbox Name="DivMetaRight">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value /></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.2cm</Top><Left>4.46cm</Left><Height>0.95cm</Height><Width>0.03cm</Width>
                <Style><BackgroundColor>#DCE6F0</BackgroundColor><Border><Style>None</Style></Border></Style>
              </Textbox>

              <!-- Place of Supply column -->
              <Textbox Name="LblPlace">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>PLACE OF SUPPLY</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.18cm</Top><Left>4.88cm</Left><Height>0.35cm</Height><Width>3.8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="ValPlace">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>West Bengal (19)</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>9.5pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.55cm</Top><Left>4.88cm</Left><Height>0.65cm</Height><Width>3.8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
            </ReportItems>
          </Rectangle>

          <!-- ================= 3. SELLER / BILL TO BOXES ================= -->
          <!-- Box Left: SELLER / ISSUED BY -->
          <Rectangle Name="BoxSeller">
            <Top>6.7cm</Top><Left>1.41cm</Left><Height>3.2cm</Height><Width>8.93cm</Width>
            <Style>
              <BackgroundColor>#FFFFFF</BackgroundColor>
              <Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.8pt</Width></Border>
            </Style>
            <ReportItems>
              <Textbox Name="TagSeller">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value /></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.28cm</Top><Left>0.42cm</Left><Height>0.35cm</Height><Width>0.09cm</Width>
                <Style><BackgroundColor>#1A74BA</BackgroundColor><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="LblSeller">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>SELLER / ISSUED BY</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.25cm</Top><Left>0.62cm</Left><Height>0.4cm</Height><Width>7.5cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>

              <Textbox Name="ValSellerName">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>AIRIQ 365 LIMITED</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>10pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.72cm</Top><Left>0.42cm</Left><Height>0.45cm</Height><Width>8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>

              <Textbox Name="ValSellerAddr">
                <Paragraphs>
                  <Paragraph><TextRuns><TextRun><Value>Ground, 1st &amp; 2nd Floor, Asmi Square</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.4pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph>
                  <Paragraph><TextRuns><TextRun><Value>Ward No. 43, 2nd Mile, Sevoke Road</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.4pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph>
                  <Paragraph><TextRuns><TextRun><Value>Siliguri – 734001, India</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.4pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph>
                </Paragraphs>
                <Top>1.20cm</Top><Left>0.42cm</Left><Height>1.1cm</Height><Width>8cm</Width>
                <Style><LineSpacing>12pt</LineSpacing><Border><Style>None</Style></Border></Style>
              </Textbox>

              <Textbox Name="ValSellerGST">
                <Paragraphs>
                  <Paragraph>
                    <TextRuns>
                      <TextRun><Value>GSTIN:  </Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun>
                      <TextRun><Value>19XXXXXXXXXX1ZX</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><Color>#6B7A90</Color></Style></TextRun>
                    </TextRuns>
                  </Paragraph>
                </Paragraphs>
                <Top>2.45cm</Top><Left>0.42cm</Left><Height>0.45cm</Height><Width>8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
            </ReportItems>
          </Rectangle>

          <!-- Box Right: BILL TO -->
          <Rectangle Name="BoxBillTo">
            <Top>6.7cm</Top><Left>10.66cm</Left><Height>3.2cm</Height><Width>8.93cm</Width>
            <Style>
              <BackgroundColor>#FFFFFF</BackgroundColor>
              <Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.8pt</Width></Border>
            </Style>
            <ReportItems>
              <Textbox Name="TagBillTo">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value /></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.28cm</Top><Left>0.42cm</Left><Height>0.35cm</Height><Width>0.09cm</Width>
                <Style><BackgroundColor>#1A74BA</BackgroundColor><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="LblBillTo">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>BILL TO</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.25cm</Top><Left>0.62cm</Left><Height>0.4cm</Height><Width>7.5cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>

              <Textbox Name="ValCustomerName">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>A. Agarwal Pvt Ltd</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>10pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.72cm</Top><Left>0.42cm</Left><Height>0.45cm</Height><Width>8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>

              <Textbox Name="ValCustomerAddr">
                <Paragraphs>
                  <Paragraph><TextRuns><TextRun><Value>Sevoke Road</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.4pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph>
                  <Paragraph><TextRuns><TextRun><Value>Siliguri, West Bengal</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.4pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph>
                  <Paragraph><TextRuns><TextRun><Value>India</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.4pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph>
                </Paragraphs>
                <Top>1.20cm</Top><Left>0.42cm</Left><Height>1.1cm</Height><Width>8cm</Width>
                <Style><LineSpacing>12pt</LineSpacing><Border><Style>None</Style></Border></Style>
              </Textbox>

              <Textbox Name="ValCustomerGST">
                <Paragraphs>
                  <Paragraph>
                    <TextRuns>
                      <TextRun><Value>GSTIN:  </Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun>
                      <TextRun><Value>19YYYYYYYYYY1ZY</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><Color>#6B7A90</Color></Style></TextRun>
                    </TextRuns>
                  </Paragraph>
                </Paragraphs>
                <Top>2.45cm</Top><Left>0.42cm</Left><Height>0.45cm</Height><Width>8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
            </ReportItems>
          </Rectangle>

          <!-- ================= 4. INVOICE DETAILS SECTION HEADER ================= -->
          <Textbox Name="LblInvoiceDetailsHeader">
            <Paragraphs><Paragraph><TextRuns><TextRun><Value>INVOICE DETAILS</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.8pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
            <Top>10.15cm</Top><Left>1.41cm</Left><Height>0.4cm</Height><Width>6cm</Width>
            <Style><Border><Style>None</Style></Border></Style>
          </Textbox>
          <Textbox Name="LblInclusiveNote">
            <Paragraphs><Paragraph><TextRuns><TextRun><Value>Rate &amp; Amount are inclusive of GST</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>6pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs>
            <Top>10.15cm</Top><Left>12.0cm</Left><Height>0.4cm</Height><Width>7.59cm</Width>
            <Style><Border><Style>None</Style></Border></Style>
          </Textbox>

          <!-- ================= 5. PASSENGERS TABLE (TABLIX) ================= -->
          <!-- Col Widths: 1.25cm, 3.7cm, 2.3cm, 2.6cm, 1.8cm, 1.2cm, 2.45cm, 2.88cm = 18.18cm -->
          <!-- Row heights: Header 0.81cm, Row1-5: 0.74cm each -->
          <Table Name="TablixPassengers">
            <Top>10.65cm</Top><Left>1.41cm</Left><Height>4.51cm</Height><Width>18.18cm</Width>
            <Style><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.8pt</Width></Border></Style>
            <Header>
              <RepeatOnNewPage>true</RepeatOnNewPage>
              <TableRows>
                <TableRow>
                  <Height>0.81cm</Height>
                  <TableCells>
                    <!-- Header Cells -->
                    <TableCell><ReportItems><Textbox Name="H_SL"><Paragraphs><Paragraph><TextRuns><TextRun><Value>SL NO.</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><BackgroundColor>#EAF3FA</BackgroundColor><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="H_Pass"><Paragraphs><Paragraph><TextRuns><TextRun><Value>PASSENGER</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><BackgroundColor>#EAF3FA</BackgroundColor><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="H_PNR"><Paragraphs><Paragraph><TextRuns><TextRun><Value>PNR</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><BackgroundColor>#EAF3FA</BackgroundColor><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="H_Date"><Paragraphs><Paragraph><TextRuns><TextRun><Value>TRAVEL DATE</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><BackgroundColor>#EAF3FA</BackgroundColor><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="H_SAC"><Paragraphs><Paragraph><TextRuns><TextRun><Value>SAC</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><BackgroundColor>#EAF3FA</BackgroundColor><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="H_Qty"><Paragraphs><Paragraph><TextRuns><TextRun><Value>QTY.</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns><Style><TextAlign>Center</TextAlign></Style></Paragraph></Paragraphs><Style><BackgroundColor>#EAF3FA</BackgroundColor><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="H_Rate"><Paragraphs><Paragraph><TextRuns><TextRun><Value>RATE</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><BackgroundColor>#EAF3FA</BackgroundColor><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="H_Amt"><Paragraphs><Paragraph><TextRuns><TextRun><Value>AMOUNT</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><BackgroundColor>#EAF3FA</BackgroundColor><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                  </TableCells>
                </TableRow>
              </TableRows>
            </Header>
            <TableColumns>
              <TableColumn><Width>1.25cm</Width></TableColumn>
              <TableColumn><Width>3.7cm</Width></TableColumn>
              <TableColumn><Width>2.3cm</Width></TableColumn>
              <TableColumn><Width>2.6cm</Width></TableColumn>
              <TableColumn><Width>1.8cm</Width></TableColumn>
              <TableColumn><Width>1.2cm</Width></TableColumn>
              <TableColumn><Width>2.45cm</Width></TableColumn>
              <TableColumn><Width>2.88cm</Width></TableColumn>
            </TableColumns>
            <Details>
              <TableRows>
                <!-- Row 1: Ram Agarwal -->
                <TableRow>
                  <Height>0.74cm</Height>
                  <TableCells>
                    <TableCell><ReportItems><Textbox Name="R1_C1"><Paragraphs><Paragraph><TextRuns><TextRun><Value>1</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R1_C2"><Paragraphs><Paragraph><TextRuns><TextRun><Value>Ram Agarwal</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8.4pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R1_C3"><Paragraphs><Paragraph><TextRuns><TextRun><Value>PNR5625X</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R1_C4"><Paragraphs><Paragraph><TextRuns><TextRun><Value>08 Sep 2026</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R1_C5"><Paragraphs><Paragraph><TextRuns><TextRun><Value>998555</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R1_C6"><Paragraphs><Paragraph><TextRuns><TextRun><Value>1</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Center</TextAlign></Style></Paragraph></Paragraphs><Style><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R1_C7"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹6,300.00</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R1_C8"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹6,300.00</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8.4pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                  </TableCells>
                </TableRow>

                <!-- Row 2: Shyam Agarwal -->
                <TableRow>
                  <Height>0.74cm</Height>
                  <TableCells>
                    <TableCell><ReportItems><Textbox Name="R2_C1"><Paragraphs><Paragraph><TextRuns><TextRun><Value>2</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R2_C2"><Paragraphs><Paragraph><TextRuns><TextRun><Value>Shyam Agarwal</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8.4pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R2_C3"><Paragraphs><Paragraph><TextRuns><TextRun><Value>PNR5625X</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R2_C4"><Paragraphs><Paragraph><TextRuns><TextRun><Value>08 Sep 2026</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R2_C5"><Paragraphs><Paragraph><TextRuns><TextRun><Value>998555</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R2_C6"><Paragraphs><Paragraph><TextRuns><TextRun><Value>1</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Center</TextAlign></Style></Paragraph></Paragraphs><Style><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R2_C7"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹6,300.00</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R2_C8"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹6,300.00</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8.4pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                  </TableCells>
                </TableRow>

                <!-- Row 3: Sita Agarwal -->
                <TableRow>
                  <Height>0.74cm</Height>
                  <TableCells>
                    <TableCell><ReportItems><Textbox Name="R3_C1"><Paragraphs><Paragraph><TextRuns><TextRun><Value>3</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R3_C2"><Paragraphs><Paragraph><TextRuns><TextRun><Value>Sita Agarwal</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8.4pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R3_C3"><Paragraphs><Paragraph><TextRuns><TextRun><Value>PNR5625X</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R3_C4"><Paragraphs><Paragraph><TextRuns><TextRun><Value>08 Sep 2026</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R3_C5"><Paragraphs><Paragraph><TextRuns><TextRun><Value>998555</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R3_C6"><Paragraphs><Paragraph><TextRuns><TextRun><Value>1</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Center</TextAlign></Style></Paragraph></Paragraphs><Style><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R3_C7"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹6,300.00</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R3_C8"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹6,300.00</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8.4pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                  </TableCells>
                </TableRow>

                <!-- Row 4: Gita Agarwal -->
                <TableRow>
                  <Height>0.74cm</Height>
                  <TableCells>
                    <TableCell><ReportItems><Textbox Name="R4_C1"><Paragraphs><Paragraph><TextRuns><TextRun><Value>4</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R4_C2"><Paragraphs><Paragraph><TextRuns><TextRun><Value>Gita Agarwal</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8.4pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R4_C3"><Paragraphs><Paragraph><TextRuns><TextRun><Value>PNR5625X</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R4_C4"><Paragraphs><Paragraph><TextRuns><TextRun><Value>08 Sep 2026</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R4_C5"><Paragraphs><Paragraph><TextRuns><TextRun><Value>998555</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R4_C6"><Paragraphs><Paragraph><TextRuns><TextRun><Value>1</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Center</TextAlign></Style></Paragraph></Paragraphs><Style><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R4_C7"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹6,300.00</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R4_C8"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹6,300.00</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8.4pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                  </TableCells>
                </TableRow>

                <!-- Row 5: Mohan Agarwal -->
                <TableRow>
                  <Height>0.74cm</Height>
                  <TableCells>
                    <TableCell><ReportItems><Textbox Name="R5_C1"><Paragraphs><Paragraph><TextRuns><TextRun><Value>5</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R5_C2"><Paragraphs><Paragraph><TextRuns><TextRun><Value>Mohan Agarwal</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8.4pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R5_C3"><Paragraphs><Paragraph><TextRuns><TextRun><Value>PNR5625X</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R5_C4"><Paragraphs><Paragraph><TextRuns><TextRun><Value>08 Sep 2026</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R5_C5"><Paragraphs><Paragraph><TextRuns><TextRun><Value>998555</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R5_C6"><Paragraphs><Paragraph><TextRuns><TextRun><Value>1</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Center</TextAlign></Style></Paragraph></Paragraphs><Style><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R5_C7"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹6,300.00</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="R5_C8"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹6,300.00</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8.4pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                  </TableCells>
                </TableRow>
              </TableRows>
            </Details>
          </Table>

          <!-- ================= 6. TAX BREAKDOWN SECTION ================= -->
          <Textbox Name="LblTaxBreakdown">
            <Paragraphs><Paragraph><TextRuns><TextRun><Value>TAX BREAKDOWN</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.8pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
            <Top>15.45cm</Top><Left>1.41cm</Left><Height>0.4cm</Height><Width>6cm</Width>
            <Style><Border><Style>None</Style></Border></Style>
          </Textbox>

          <!-- Tax Table -->
          <!-- Col Widths: 7.25cm, 5.46cm, 5.47cm = 18.18cm -->
          <!-- Header 0.67cm, Rows 0.60cm each -->
          <Table Name="TablixTax">
            <Top>15.9cm</Top><Left>1.41cm</Left><Height>1.87cm</Height><Width>18.18cm</Width>
            <Style><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.8pt</Width></Border></Style>
            <Header>
              <TableRows>
                <TableRow>
                  <Height>0.67cm</Height>
                  <TableCells>
                    <TableCell><ReportItems><Textbox Name="TH_Tax"><Paragraphs><Paragraph><TextRuns><TextRun><Value>TAX</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><BackgroundColor>#EAF3FA</BackgroundColor><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="TH_Rate"><Paragraphs><Paragraph><TextRuns><TextRun><Value>RATE</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns><Style><TextAlign>Center</TextAlign></Style></Paragraph></Paragraphs><Style><BackgroundColor>#EAF3FA</BackgroundColor><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="TH_Amt"><Paragraphs><Paragraph><TextRuns><TextRun><Value>TAX AMOUNT</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><BackgroundColor>#EAF3FA</BackgroundColor><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                  </TableCells>
                </TableRow>
              </TableRows>
            </Header>
            <TableColumns>
              <TableColumn><Width>7.25cm</Width></TableColumn>
              <TableColumn><Width>5.46cm</Width></TableColumn>
              <TableColumn><Width>5.47cm</Width></TableColumn>
            </TableColumns>
            <Details>
              <TableRows>
                <!-- CGST Row -->
                <TableRow>
                  <Height>0.60cm</Height>
                  <TableCells>
                    <TableCell><ReportItems><Textbox Name="TR1_C1"><Paragraphs><Paragraph><TextRuns><TextRun><Value>CGST</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="TR1_C2"><Paragraphs><Paragraph><TextRuns><TextRun><Value>9%</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Center</TextAlign></Style></Paragraph></Paragraphs><Style><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="TR1_C3"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹101.25</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                  </TableCells>
                </TableRow>
                <!-- SGST Row -->
                <TableRow>
                  <Height>0.60cm</Height>
                  <TableCells>
                    <TableCell><ReportItems><Textbox Name="TR2_C1"><Paragraphs><Paragraph><TextRuns><TextRun><Value>SGST</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Style><PaddingLeft>6pt</PaddingLeft><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="TR2_C2"><Paragraphs><Paragraph><TextRuns><TextRun><Value>9%</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Center</TextAlign></Style></Paragraph></Paragraphs><Style><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                    <TableCell><ReportItems><Textbox Name="TR2_C3"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹101.25</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Style><PaddingRight>6pt</PaddingRight><VerticalAlign>Middle</VerticalAlign><Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.6pt</Width></Border></Style></Textbox></ReportItems></TableCell>
                  </TableCells>
                </TableRow>
              </TableRows>
            </Details>
          </Table>

          <!-- GST Legal Note -->
          <Textbox Name="TxtGSTNote">
            <Paragraphs><Paragraph><TextRuns><TextRun><Value>GST on Air Travel Agent's service under Rule 32(3), CGST Rules, 2017 (value deemed at 5% of basic fare for domestic / 10% for international). GST included in invoice value.</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
            <Top>17.85cm</Top><Left>1.41cm</Left><Height>0.4cm</Height><Width>18.18cm</Width>
            <Style><Border><Style>None</Style></Border></Style>
          </Textbox>

          <!-- ================= 7. AMOUNT IN WORDS & TOTALS BOXES ================= -->
          <!-- Box Left: AMOUNT IN WORDS -->
          <Rectangle Name="BoxAmountWords">
            <Top>18.35cm</Top><Left>1.41cm</Left><Height>2.15cm</Height><Width>8.93cm</Width>
            <Style>
              <BackgroundColor>#FFFFFF</BackgroundColor>
              <Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.8pt</Width></Border>
            </Style>
            <ReportItems>
              <Textbox Name="LblWords">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>AMOUNT IN WORDS</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.22cm</Top><Left>0.42cm</Left><Height>0.35cm</Height><Width>8cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="ValWords">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>Indian Rupees Thirty-One Thousand Five Hundred Only</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.65cm</Top><Left>0.42cm</Left><Height>1.25cm</Height><Width>8.1cm</Width>
                <Style><LineSpacing>13pt</LineSpacing><Border><Style>None</Style></Border></Style>
              </Textbox>
            </ReportItems>
          </Rectangle>

          <!-- Box Right: SUMMARY & TOTAL BAR -->
          <!-- 3 rows of subtotal + 1 blue total bar -->
          <Textbox Name="LblValExclGST"><Paragraphs><Paragraph><TextRuns><TextRun><Value>Value excl. GST</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.6pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>18.42cm</Top><Left>11.5cm</Left><Height>0.4cm</Height><Width>4cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>
          <Textbox Name="ValExclGST"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹31,297.50</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.6pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Top>18.42cm</Top><Left>15.5cm</Left><Height>0.4cm</Height><Width>4.09cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>

          <Textbox Name="LblCGSTVal"><Paragraphs><Paragraph><TextRuns><TextRun><Value>CGST @ 9%</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.6pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>18.91cm</Top><Left>11.5cm</Left><Height>0.4cm</Height><Width>4cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>
          <Textbox Name="ValCGSTVal"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹101.25</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.6pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Top>18.91cm</Top><Left>15.5cm</Left><Height>0.4cm</Height><Width>4.09cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>

          <Textbox Name="LblSGSTVal"><Paragraphs><Paragraph><TextRuns><TextRun><Value>SGST @ 9%</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.6pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>19.40cm</Top><Left>11.5cm</Left><Height>0.4cm</Height><Width>4cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>
          <Textbox Name="ValSGSTVal"><Paragraphs><Paragraph><TextRuns><TextRun><Value>₹101.25</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.6pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs><Top>19.40cm</Top><Left>15.5cm</Left><Height>0.4cm</Height><Width>4.09cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>

          <!-- Deep Blue INVOICE TOTAL BAR -->
          <!-- With Left Coral accent strip (0.35cm) and blue body (7.35cm) = 7.70cm -->
          <Rectangle Name="BoxTotalBar">
            <Top>20.0cm</Top><Left>11.89cm</Left><Height>0.85cm</Height><Width>7.70cm</Width>
            <Style>
              <BackgroundColor>#1A74BA</BackgroundColor>
              <Border><Style>None</Style></Border>
            </Style>
            <ReportItems>
              <Textbox Name="CoralStripTotal">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value /></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0cm</Top><Left>0cm</Left><Height>0.85cm</Height><Width>0.25cm</Width>
                <Style><BackgroundColor>#F2666E</BackgroundColor><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="LblInvTotal">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>INVOICE TOTAL</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>6.8pt</FontSize><FontWeight>Bold</FontWeight><Color>#FFFFFF</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.22cm</Top><Left>0.45cm</Left><Height>0.45cm</Height><Width>3.0cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="ValInvTotal">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>₹31,500.00</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>12pt</FontSize><FontWeight>Bold</FontWeight><Color>#FFFFFF</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs>
                <Top>0.10cm</Top><Left>3.5cm</Left><Height>0.65cm</Height><Width>3.9cm</Width>
                <Style><PaddingRight>6pt</PaddingRight><Border><Style>None</Style></Border></Style>
              </Textbox>
            </ReportItems>
          </Rectangle>

          <!-- ================= 8. NARRATION BOX ================= -->
          <Rectangle Name="BoxNarration">
            <Top>21.1cm</Top><Left>1.41cm</Left><Height>1.20cm</Height><Width>18.18cm</Width>
            <Style>
              <BackgroundColor>#F6F9FC</BackgroundColor>
              <Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.8pt</Width></Border>
            </Style>
            <ReportItems>
              <Textbox Name="TagNarration">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value /></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.22cm</Top><Left>0.42cm</Left><Height>0.35cm</Height><Width>0.09cm</Width>
                <Style><BackgroundColor>#1A74BA</BackgroundColor><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="LblNarration">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>NARRATION</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.20cm</Top><Left>0.62cm</Left><Height>0.35cm</Height><Width>5cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="ValNarration">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>Being air tickets issued to A. Agarwal Pvt Ltd for 5 passengers (Ram Agarwal + 4) on PNR5625X, travel date 08 Sep 2026.</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.4pt</FontSize><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.58cm</Top><Left>0.42cm</Left><Height>0.52cm</Height><Width>17.2cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
            </ReportItems>
          </Rectangle>

          <!-- ================= 9. BANK DETAILS & CONTACT DETAILS ================= -->
          <!-- Box Left: BANK DETAILS -->
          <Rectangle Name="BoxBank">
            <Top>22.55cm</Top><Left>1.41cm</Left><Height>1.65cm</Height><Width>8.93cm</Width>
            <Style>
              <BackgroundColor>#FFFFFF</BackgroundColor>
              <Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.8pt</Width></Border>
            </Style>
            <ReportItems>
              <Textbox Name="LblBankDetails">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>BANK DETAILS</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>0.18cm</Top><Left>0.42cm</Left><Height>0.35cm</Height><Width>5cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>

              <Textbox Name="LblBank"><Paragraphs><Paragraph><TextRuns><TextRun><Value>Bank</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>0.55cm</Top><Left>0.42cm</Left><Height>0.32cm</Height><Width>2.2cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>
              <Textbox Name="ValBank"><Paragraphs><Paragraph><TextRuns><TextRun><Value>State Bank of India</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>0.55cm</Top><Left>2.7cm</Left><Height>0.32cm</Height><Width>5.8cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>

              <Textbox Name="LblAcc"><Paragraphs><Paragraph><TextRuns><TextRun><Value>Account No.</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>0.88cm</Top><Left>0.42cm</Left><Height>0.32cm</Height><Width>2.2cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>
              <Textbox Name="ValAcc"><Paragraphs><Paragraph><TextRuns><TextRun><Value>SBI 133667466</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>0.88cm</Top><Left>2.7cm</Left><Height>0.32cm</Height><Width>5.8cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>

              <Textbox Name="LblIFSC"><Paragraphs><Paragraph><TextRuns><TextRun><Value>IFSC</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>1.21cm</Top><Left>0.42cm</Left><Height>0.32cm</Height><Width>2.2cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>
              <Textbox Name="ValIFSC"><Paragraphs><Paragraph><TextRuns><TextRun><Value>—</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>1.21cm</Top><Left>2.7cm</Left><Height>0.32cm</Height><Width>5.8cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>
            </ReportItems>
          </Rectangle>

          <!-- Box Right: CONTACT DETAILS -->
          <Rectangle Name="BoxContact">
            <Top>22.55cm</Top><Left>10.66cm</Left><Height>1.65cm</Height><Width>8.93cm</Width>
            <Style>
              <BackgroundColor>#FFFFFF</BackgroundColor>
              <Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.8pt</Width></Border>
            </Style>
            <ReportItems>
              <Textbox Name="LblContactDetails">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>CONTACT DETAILS</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>0.18cm</Top><Left>0.42cm</Left><Height>0.35cm</Height><Width>5cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>

              <Textbox Name="LblWebsite"><Paragraphs><Paragraph><TextRuns><TextRun><Value>Website</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>0.55cm</Top><Left>0.42cm</Left><Height>0.32cm</Height><Width>2.2cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>
              <Textbox Name="ValWebsite"><Paragraphs><Paragraph><TextRuns><TextRun><Value>airiq.in</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>0.55cm</Top><Left>2.7cm</Left><Height>0.32cm</Height><Width>5.8cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>

              <Textbox Name="LblEmail"><Paragraphs><Paragraph><TextRuns><TextRun><Value>Email</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>0.88cm</Top><Left>0.42cm</Left><Height>0.32cm</Height><Width>2.2cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>
              <Textbox Name="ValEmail"><Paragraphs><Paragraph><TextRuns><TextRun><Value>accounts@airiq.in</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7.2pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>0.88cm</Top><Left>2.7cm</Left><Height>0.32cm</Height><Width>5.8cm</Width><Style><Border><Style>None</Style></Border></Style></Textbox>
            </ReportItems>
          </Rectangle>

          <!-- ================= 10. DECLARATION & SIGNATURE ================= -->
          <!-- Box Left: DECLARATION -->
          <Rectangle Name="BoxDeclaration">
            <Top>24.45cm</Top><Left>1.41cm</Left><Height>1.62cm</Height><Width>8.93cm</Width>
            <Style>
              <BackgroundColor>#FFFFFF</BackgroundColor>
              <Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.8pt</Width></Border>
            </Style>
            <ReportItems>
              <Textbox Name="LblDeclaration">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>DECLARATION</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>5.6pt</FontSize><FontWeight>Bold</FontWeight><Color>#1A74BA</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs><Top>0.18cm</Top><Left>0.42cm</Left><Height>0.35cm</Height><Width>5cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
              <Textbox Name="ValDeclarationText">
                <Paragraphs>
                  <Paragraph><TextRuns><TextRun><Value>We declare that this invoice shows the actual price of the services described and that all particulars are true and correct.</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>6.6pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph>
                </Paragraphs>
                <Top>0.55cm</Top><Left>0.42cm</Left><Height>0.95cm</Height><Width>8.1cm</Width>
                <Style><LineSpacing>10.5pt</LineSpacing><Border><Style>None</Style></Border></Style>
              </Textbox>
            </ReportItems>
          </Rectangle>

          <!-- Box Right: SIGNATURE & SEAL -->
          <Rectangle Name="BoxSignature">
            <Top>24.45cm</Top><Left>10.66cm</Left><Height>1.62cm</Height><Width>8.93cm</Width>
            <Style>
              <BackgroundColor>#FFFFFF</BackgroundColor>
              <Border><Color>#DCE6F0</Color><Style>Solid</Style><Width>0.8pt</Width></Border>
            </Style>
            <ReportItems>
              <Textbox Name="ValForCompany">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>for AIRIQ 365 LIMITED</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>8pt</FontSize><FontWeight>Bold</FontWeight><Color>#14233C</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs>
                <Top>0.18cm</Top><Left>2.0cm</Left><Height>0.4cm</Height><Width>6.51cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>

              <!-- Dashed line for signature -->
              <Textbox Name="DashedLineSig">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value /></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>1.05cm</Top><Left>2.5cm</Left><Height>0.02cm</Height><Width>6.01cm</Width>
                <Style><Border><Color>#DCE6F0</Color><Style>Dashed</Style><Width>0.8pt</Width></Border></Style>
              </Textbox>

              <Textbox Name="LblSeal">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>Seal</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
                <Top>1.15cm</Top><Left>0.42cm</Left><Height>0.35cm</Height><Width>2cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>

              <Textbox Name="LblSignatory">
                <Paragraphs><Paragraph><TextRuns><TextRun><Value>Authorised Signatory</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>7pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs>
                <Top>1.15cm</Top><Left>2.5cm</Left><Height>0.35cm</Height><Width>6.01cm</Width>
                <Style><Border><Style>None</Style></Border></Style>
              </Textbox>
            </ReportItems>
          </Rectangle>

          <!-- ================= 11. FOOTER LINE & TEXT ================= -->
          <!-- Thin footer line -->
          <Textbox Name="FooterLine">
            <Paragraphs><Paragraph><TextRuns><TextRun><Value /></TextRun></TextRuns></Paragraph></Paragraphs>
            <Top>27.86cm</Top><Left>1.41cm</Left><Height>0.03cm</Height><Width>18.18cm</Width>
            <Style><BackgroundColor>#DCE6F0</BackgroundColor><Border><Style>None</Style></Border></Style>
          </Textbox>
          <!-- Footer Coral accent -->
          <Textbox Name="FooterAccentCoral">
            <Paragraphs><Paragraph><TextRuns><TextRun><Value /></TextRun></TextRuns></Paragraph></Paragraphs>
            <Top>27.86cm</Top><Left>1.41cm</Left><Height>0.06cm</Height><Width>1.76cm</Width>
            <Style><BackgroundColor>#F2666E</BackgroundColor><Border><Style>None</Style></Border></Style>
          </Textbox>

          <Textbox Name="FooterLeft">
            <Paragraphs><Paragraph><TextRuns><TextRun><Value>This is a computer-generated invoice.  Subject to Siliguri jurisdiction.</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>6.4pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns></Paragraph></Paragraphs>
            <Top>28.05cm</Top><Left>1.41cm</Left><Height>0.4cm</Height><Width>11cm</Width>
            <Style><Border><Style>None</Style></Border></Style>
          </Textbox>

          <Textbox Name="FooterRight">
            <Paragraphs><Paragraph><TextRuns><TextRun><Value>airiq.in  |  Page 1 of 1</Value><Style><FontFamily>Segoe UI</FontFamily><FontSize>6.4pt</FontSize><Color>#6B7A90</Color></Style></TextRun></TextRuns><Style><TextAlign>Right</TextAlign></Style></Paragraph></Paragraphs>
            <Top>28.05cm</Top><Left>13.0cm</Left><Height>0.4cm</Height><Width>6.59cm</Width>
            <Style><Border><Style>None</Style></Border></Style>
          </Textbox>

        </ReportItems>
      </Body>
      <Width>21.0cm</Width>
      <Page>
        <PageHeight>29.7cm</PageHeight>
        <PageWidth>21.0cm</PageWidth>
        <LeftMargin>0cm</LeftMargin>
        <RightMargin>0cm</RightMargin>
        <TopMargin>0cm</TopMargin>
        <BottomMargin>0cm</BottomMargin>
        <Style />
      </Page>
    </ReportSection>
  </ReportSections>
  <EmbeddedImages>
    <EmbeddedImage Name="QRCodeImage">
      <MIMEType>image/png</MIMEType>
      <ImageData>{qr_b64}</ImageData>
    </EmbeddedImage>
  </EmbeddedImages>
  <rd:ReportUnitType>Cm</rd:ReportUnitType>
</Report>'''

with open('design.rdl', 'w', encoding='utf-8') as out:
    out.write(rdl_content)
print('Successfully created design.rdl!')
