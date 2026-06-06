object dm: Tdm
  OldCreateOrder = False
  Height = 397
  Width = 547
  object conProjetoVenda: TFDConnection
    Params.Strings = (
      'Database=ProjetoVenda'
      'User_Name=sa'
      'Password=123456'
      'Server=localhost\SQLSERVER2022'
      'DriverID=MSSQL')
    Connected = True
    LoginPrompt = False
    Left = 248
    Top = 24
  end
  object stInsereCliente: TFDStoredProc
    Connection = conProjetoVenda
    StoredProcName = 'ProjetoVenda.dbo.st_InsereCli'
    Left = 136
    Top = 104
    ParamData = <
      item
        Position = 1
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        ParamType = ptResult
      end
      item
        Position = 2
        Name = '@nome'
        DataType = ftString
        ParamType = ptInput
        Size = 50
      end>
  end
  object qryClienets: TFDQuery
    Active = True
    Connection = conProjetoVenda
    SQL.Strings = (
      'SELECT * FROM TBCLIENTES')
    Left = 136
    Top = 168
    object qryClienetsID_CLI: TFDAutoIncField
      Alignment = taCenter
      DisplayLabel = 'Cod'
      FieldName = 'ID_CLI'
      Origin = 'ID_CLI'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object qryClienetsNOME_CLI: TStringField
      DisplayLabel = 'Nome Cliente'
      FieldName = 'NOME_CLI'
      Origin = 'NOME_CLI'
      Size = 50
    end
  end
  object dsClientes: TDataSource
    DataSet = qryClienets
    Left = 88
    Top = 240
  end
  object stAtualizaCliente: TFDStoredProc
    Connection = conProjetoVenda
    StoredProcName = 'ProjetoVenda.dbo.st_AlteraCli'
    Left = 40
    Top = 104
    ParamData = <
      item
        Position = 1
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        ParamType = ptResult
      end
      item
        Position = 2
        Name = '@id'
        DataType = ftInteger
        ParamType = ptInput
      end
      item
        Position = 3
        Name = '@nome'
        DataType = ftString
        ParamType = ptInput
        Size = 50
      end>
  end
  object stExcluiCliente: TFDStoredProc
    Connection = conProjetoVenda
    StoredProcName = 'ProjetoVenda.dbo.ST_APAGACLI'
    Left = 40
    Top = 168
    ParamData = <
      item
        Position = 1
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        ParamType = ptResult
      end
      item
        Position = 2
        Name = '@ID'
        DataType = ftInteger
        ParamType = ptInput
      end>
  end
  object qryProdutos: TFDQuery
    Active = True
    Connection = conProjetoVenda
    SQL.Strings = (
      'select * from tbprodutos')
    Left = 328
    Top = 112
    object qryProdutosID_PROD: TFDAutoIncField
      FieldName = 'ID_PROD'
      Origin = 'ID_PROD'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object qryProdutosNOME_PROD: TStringField
      FieldName = 'NOME_PROD'
      Origin = 'NOME_PROD'
      Size = 50
    end
    object qryProdutosQTD_PROD: TIntegerField
      FieldName = 'QTD_PROD'
      Origin = 'QTD_PROD'
    end
    object qryProdutosVL_PROD: TCurrencyField
      FieldName = 'VL_PROD'
      Origin = 'VL_PROD'
    end
  end
  object dsProdutos: TDataSource
    DataSet = qryProdutos
    Left = 328
    Top = 176
  end
  object stAtualizaProduto: TFDStoredProc
    Connection = conProjetoVenda
    StoredProcName = 'ProjetoVenda.dbo.st_AtualizaProd'
    Left = 416
    Top = 232
    ParamData = <
      item
        Position = 1
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        ParamType = ptResult
      end
      item
        Position = 2
        Name = '@id'
        DataType = ftInteger
        ParamType = ptInput
      end
      item
        Position = 3
        Name = '@nome'
        DataType = ftString
        ParamType = ptInput
        Size = 50
      end
      item
        Position = 4
        Name = '@qtd'
        DataType = ftInteger
        ParamType = ptInput
      end
      item
        Position = 5
        Name = '@vl'
        DataType = ftCurrency
        Precision = 19
        NumericScale = 4
        ParamType = ptInput
      end>
  end
  object stInsereProduto: TFDStoredProc
    Connection = conProjetoVenda
    StoredProcName = 'ProjetoVenda.dbo.st_InsereProd'
    Left = 328
    Top = 232
    ParamData = <
      item
        Position = 1
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        ParamType = ptResult
      end
      item
        Position = 2
        Name = '@nome'
        DataType = ftString
        ParamType = ptInput
        Size = 50
      end
      item
        Position = 3
        Name = '@qtd'
        DataType = ftInteger
        ParamType = ptInput
      end
      item
        Position = 4
        Name = '@vl'
        DataType = ftCurrency
        Precision = 19
        NumericScale = 4
        ParamType = ptInput
      end>
  end
  object stExcluiProduto: TFDStoredProc
    Connection = conProjetoVenda
    StoredProcName = 'ProjetoVenda.dbo.stExcluiProd'
    Left = 368
    Top = 304
    ParamData = <
      item
        Position = 1
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        ParamType = ptResult
      end
      item
        Position = 2
        Name = '@id'
        DataType = ftInteger
        ParamType = ptInput
      end>
  end
  object stInsereItensVenda: TFDStoredProc
    Connection = conProjetoVenda
    StoredProcName = 'ProjetoVenda.dbo.st_InsereItensVenda'
    Left = 160
    Top = 328
    ParamData = <
      item
        Position = 1
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        ParamType = ptResult
        Value = 0
      end
      item
        Position = 2
        Name = '@nm_Prod'
        DataType = ftString
        ParamType = ptInput
        Size = 50
      end
      item
        Position = 3
        Name = '@qtdVenda'
        DataType = ftInteger
        ParamType = ptInput
      end
      item
        Position = 4
        Name = '@codVEnda'
        DataType = ftInteger
        ParamType = ptInput
      end
      item
        Position = 5
        Name = '@erMsg'
        DataType = ftString
        ParamType = ptInputOutput
        Size = 255
        Value = ''
      end
      item
        Position = 6
        Name = '@return'
        DataType = ftInteger
        ParamType = ptInputOutput
        Value = 1
      end>
  end
  object stInsereVenda: TFDStoredProc
    Connection = conProjetoVenda
    StoredProcName = 'ProjetoVenda.dbo.st_InsereVenda'
    Left = 256
    Top = 328
    ParamData = <
      item
        Position = 1
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        ParamType = ptResult
      end
      item
        Position = 2
        Name = '@idCli'
        DataType = ftInteger
        ParamType = ptInput
      end
      item
        Position = 3
        Name = '@total'
        DataType = ftCurrency
        Precision = 19
        NumericScale = 4
        ParamType = ptInput
      end
      item
        Position = 4
        Name = '@codVenda'
        DataType = ftInteger
        ParamType = ptInput
      end>
  end
  object qryCodVenda: TFDQuery
    Connection = conProjetoVenda
    SQL.Strings = (
      'SELECT MAX(ID_Cod_Venda) FROM TBVENDAS')
    Left = 208
    Top = 280
    object qryCodVendaUnnamed1: TIntegerField
      FieldName = 'Unnamed1'
      Origin = 'Unnamed1'
      ReadOnly = True
    end
  end
end
