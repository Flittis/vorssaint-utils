// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Strings for uploading a screenshot or recording to a server, shared by
/// both tools.
struct CaptureUploadStrings {
    let sectionTitle: String
    let enabledToggle: String
    let screenshotCaption: String
    let recordingCaption: String
    let fileNameCaption: String
    let addressLabel: String
    let addressInvalid: String
    let parametersTitle: String
    let headersTitle: String
    let namePlaceholder: String
    let valuePlaceholder: String
    let addParameter: String
    let addHeader: String
    let removeRow: String
    let headerNameInvalid: String
    let valuesStayCaption: String
    let copyLinkToggle: String
    let replyCaption: String
    let menuItemFormat: String
    let uploadingHUD: String
    let uploadedFormat: String
    let failedHUD: String
    let rejectedFormat: String
}

extension FeatureStrings {
    static func captureUpload(_ language: AppLanguage) -> CaptureUploadStrings {
        switch language {
        case .enUS: return .enUS
        case .ptBR: return .ptBR
        case .tr: return .tr
        case .ru: return .ru
        case .es: return .es
        case .sk: return .sk
        case .de: return .de
        case .fr: return .fr
        case .it: return .it
        case .ja: return .ja
        case .ko: return .ko
        case .zhHans: return .zhHans
        case .zhTW: return .zhTW
        case .zhHK: return .zhHK
        case .uk: return .uk
        }
    }
}

extension CaptureUploadStrings {
    static let enUS = CaptureUploadStrings(
        sectionTitle: "Upload to server",
        enabledToggle: "Allow upload to server",
        screenshotCaption: "Send a screenshot to a server. The file is the body of one HTTPS POST request, with its type in Content-Type.",
        recordingCaption: "Send a recording to a server. The file is the body of one HTTPS POST request, with its type in Content-Type. It is compressed on this Mac to fit under 100 MB first, as for temporary links.",
        fileNameCaption: "The file’s name travels in an X-File-Name header, percent-encoded outside ASCII.",
        addressLabel: "Address",
        addressInvalid: "Enter a full https:// address.",
        parametersTitle: "Query parameters",
        headersTitle: "Headers",
        namePlaceholder: "Name",
        valuePlaceholder: "Value",
        addParameter: "Add parameter",
        addHeader: "Add header",
        removeRow: "Remove",
        headerNameInvalid: "This name cannot be used for a header.",
        valuesStayCaption: "Values stay on this Mac. A settings backup carries the address and the names only.",
        copyLinkToggle: "Copy the link after upload",
        replyCaption: "The link is read from the reply, as JSON with a url field or as plain text.",
        menuItemFormat: "Upload to %@",
        uploadingHUD: "Uploading…",
        uploadedFormat: "Uploaded to %@",
        failedHUD: "The upload failed",
        rejectedFormat: "The server refused the upload (HTTP %d)"
    )

    static let ptBR = CaptureUploadStrings(
        sectionTitle: "Envio para servidor",
        enabledToggle: "Permitir envio para servidor",
        screenshotCaption: "Envie uma captura de tela para um servidor. O arquivo é o corpo de uma única solicitação HTTPS POST, com o tipo em Content-Type.",
        recordingCaption: "Envie uma gravação para um servidor. O arquivo é o corpo de uma única solicitação HTTPS POST, com o tipo em Content-Type. Ela é comprimida neste Mac para ficar abaixo de 100 MB antes, como nos links temporários.",
        fileNameCaption: "O nome do arquivo vai no cabeçalho X-File-Name, com codificação percentual fora do ASCII.",
        addressLabel: "Endereço",
        addressInvalid: "Digite um endereço https:// completo.",
        parametersTitle: "Parâmetros de consulta",
        headersTitle: "Cabeçalhos",
        namePlaceholder: "Nome",
        valuePlaceholder: "Valor",
        addParameter: "Adicionar parâmetro",
        addHeader: "Adicionar cabeçalho",
        removeRow: "Remover",
        headerNameInvalid: "Este nome não pode ser usado em um cabeçalho.",
        valuesStayCaption: "Os valores ficam neste Mac. Um backup das configurações leva apenas o endereço e os nomes.",
        copyLinkToggle: "Copiar o link após o envio",
        replyCaption: "O link é lido da resposta, como JSON com um campo url ou como texto simples.",
        menuItemFormat: "Enviar para %@",
        uploadingHUD: "Enviando…",
        uploadedFormat: "Enviado para %@",
        failedHUD: "Falha no envio",
        rejectedFormat: "O servidor recusou o envio (HTTP %d)"
    )

    static let tr = CaptureUploadStrings(
        sectionTitle: "Sunucuya yükleme",
        enabledToggle: "Sunucuya yüklemeye izin ver",
        screenshotCaption: "Bir ekran görüntüsünü bir sunucuya gönderin. Dosya, türü Content-Type içinde belirtilen tek bir HTTPS POST isteğinin gövdesidir.",
        recordingCaption: "Bir kaydı bir sunucuya gönderin. Dosya, türü Content-Type içinde belirtilen tek bir HTTPS POST isteğinin gövdesidir. Kayıt, geçici bağlantılarda olduğu gibi önce bu Mac’te 100 MB altında kalacak şekilde sıkıştırılır.",
        fileNameCaption: "Dosya adı, ASCII dışındaki karakterler yüzde kodlamasıyla, X-File-Name üst bilgisinde gönderilir.",
        addressLabel: "Adres",
        addressInvalid: "Tam bir https:// adresi girin.",
        parametersTitle: "Sorgu parametreleri",
        headersTitle: "Üst bilgiler",
        namePlaceholder: "Ad",
        valuePlaceholder: "Değer",
        addParameter: "Parametre ekle",
        addHeader: "Üst bilgi ekle",
        removeRow: "Kaldır",
        headerNameInvalid: "Bu ad bir üst bilgi için kullanılamaz.",
        valuesStayCaption: "Değerler bu Mac’te kalır. Ayar yedeği yalnızca adresi ve adları taşır.",
        copyLinkToggle: "Yüklemeden sonra bağlantıyı kopyala",
        replyCaption: "Bağlantı, url alanı olan JSON veya düz metin olarak yanıttan okunur.",
        menuItemFormat: "%@ adresine yükle",
        uploadingHUD: "Yükleniyor…",
        uploadedFormat: "%@ adresine yüklendi",
        failedHUD: "Yükleme başarısız oldu",
        rejectedFormat: "Sunucu yüklemeyi reddetti (HTTP %d)"
    )

    static let ru = CaptureUploadStrings(
        sectionTitle: "Загрузка на сервер",
        enabledToggle: "Разрешить загрузку на сервер",
        screenshotCaption: "Отправляйте снимок экрана на сервер. Файл передаётся телом одного запроса HTTPS POST, а его тип указан в Content-Type.",
        recordingCaption: "Отправляйте запись на сервер. Файл передаётся телом одного запроса HTTPS POST, а его тип указан в Content-Type. Запись сначала сжимается на этом Mac до размера менее 100 МБ, как и для временных ссылок.",
        fileNameCaption: "Имя файла передаётся в заголовке X-File-Name; символы вне ASCII кодируются процентами.",
        addressLabel: "Адрес",
        addressInvalid: "Введите полный адрес https://.",
        parametersTitle: "Параметры запроса",
        headersTitle: "Заголовки",
        namePlaceholder: "Имя",
        valuePlaceholder: "Значение",
        addParameter: "Добавить параметр",
        addHeader: "Добавить заголовок",
        removeRow: "Удалить",
        headerNameInvalid: "Это имя нельзя использовать для заголовка.",
        valuesStayCaption: "Значения остаются на этом Mac. Резервная копия настроек содержит только адрес и имена.",
        copyLinkToggle: "Копировать ссылку после загрузки",
        replyCaption: "Ссылка берётся из ответа: из JSON с полем url или из простого текста.",
        menuItemFormat: "Загрузить на %@",
        uploadingHUD: "Загрузка…",
        uploadedFormat: "Загружено на %@",
        failedHUD: "Не удалось загрузить",
        rejectedFormat: "Сервер отклонил загрузку (HTTP %d)"
    )

    static let es = CaptureUploadStrings(
        sectionTitle: "Subir a un servidor",
        enabledToggle: "Permitir subir a un servidor",
        screenshotCaption: "Envía una captura de pantalla a un servidor. El archivo es el cuerpo de una única solicitud HTTPS POST, con su tipo en Content-Type.",
        recordingCaption: "Envía una grabación a un servidor. El archivo es el cuerpo de una única solicitud HTTPS POST, con su tipo en Content-Type. Antes se comprime en este Mac para quedar por debajo de 100 MB, como en los enlaces temporales.",
        fileNameCaption: "El nombre del archivo viaja en la cabecera X-File-Name, con codificación porcentual fuera de ASCII.",
        addressLabel: "Dirección",
        addressInvalid: "Introduce una dirección https:// completa.",
        parametersTitle: "Parámetros de consulta",
        headersTitle: "Cabeceras",
        namePlaceholder: "Nombre",
        valuePlaceholder: "Valor",
        addParameter: "Añadir parámetro",
        addHeader: "Añadir cabecera",
        removeRow: "Eliminar",
        headerNameInvalid: "Este nombre no se puede usar en una cabecera.",
        valuesStayCaption: "Los valores se quedan en este Mac. Una copia de seguridad de los ajustes solo lleva la dirección y los nombres.",
        copyLinkToggle: "Copiar el enlace tras la subida",
        replyCaption: "El enlace se lee de la respuesta, como JSON con un campo url o como texto sin formato.",
        menuItemFormat: "Subir a %@",
        uploadingHUD: "Subiendo…",
        uploadedFormat: "Subido a %@",
        failedHUD: "No se pudo subir",
        rejectedFormat: "El servidor rechazó la subida (HTTP %d)"
    )

    static let sk = CaptureUploadStrings(
        sectionTitle: "Odosielanie na server",
        enabledToggle: "Povoliť odosielanie na server",
        screenshotCaption: "Odošlite snímku obrazovky na server. Súbor tvorí telo jednej požiadavky HTTPS POST a jeho typ je uvedený v hlavičke Content-Type.",
        recordingCaption: "Odošlite nahrávku na server. Súbor tvorí telo jednej požiadavky HTTPS POST a jeho typ je uvedený v hlavičke Content-Type. Nahrávka sa najprv na tomto Macu skomprimuje pod 100 MB, rovnako ako pri dočasných odkazoch.",
        fileNameCaption: "Názov súboru sa posiela v hlavičke X-File-Name, znaky mimo ASCII sú percentovo kódované.",
        addressLabel: "Adresa",
        addressInvalid: "Zadajte úplnú adresu začínajúcu https://.",
        parametersTitle: "Parametre dopytu",
        headersTitle: "Hlavičky",
        namePlaceholder: "Názov",
        valuePlaceholder: "Hodnota",
        addParameter: "Pridať parameter",
        addHeader: "Pridať hlavičku",
        removeRow: "Odstrániť",
        headerNameInvalid: "Tento názov nemožno použiť pre hlavičku.",
        valuesStayCaption: "Hodnoty zostávajú na tomto Macu. Záloha nastavení obsahuje iba adresu a názvy.",
        copyLinkToggle: "Po odoslaní skopírovať odkaz",
        replyCaption: "Odkaz sa číta z odpovede, ako JSON s poľom url alebo ako obyčajný text.",
        menuItemFormat: "Odoslať na %@",
        uploadingHUD: "Odosiela sa…",
        uploadedFormat: "Odoslané na %@",
        failedHUD: "Odoslanie zlyhalo",
        rejectedFormat: "Server odmietol odoslanie (HTTP %d)"
    )

    static let de = CaptureUploadStrings(
        sectionTitle: "Auf einen Server hochladen",
        enabledToggle: "Hochladen auf einen Server erlauben",
        screenshotCaption: "Sende ein Bildschirmfoto an einen Server. Die Datei ist der Inhalt einer einzelnen HTTPS-POST-Anfrage, ihr Typ steht in Content-Type.",
        recordingCaption: "Sende eine Aufnahme an einen Server. Die Datei ist der Inhalt einer einzelnen HTTPS-POST-Anfrage, ihr Typ steht in Content-Type. Die Aufnahme wird zuvor auf diesem Mac auf unter 100 MB komprimiert, wie bei temporären Links.",
        fileNameCaption: "Der Dateiname steht im Header X-File-Name, außerhalb von ASCII prozentkodiert.",
        addressLabel: "Adresse",
        addressInvalid: "Gib eine vollständige https://-Adresse ein.",
        parametersTitle: "Abfrageparameter",
        headersTitle: "Header",
        namePlaceholder: "Name",
        valuePlaceholder: "Wert",
        addParameter: "Parameter hinzufügen",
        addHeader: "Header hinzufügen",
        removeRow: "Entfernen",
        headerNameInvalid: "Dieser Name kann nicht für einen Header verwendet werden.",
        valuesStayCaption: "Werte bleiben auf diesem Mac. Ein Einstellungs-Backup enthält nur die Adresse und die Namen.",
        copyLinkToggle: "Link nach dem Hochladen kopieren",
        replyCaption: "Der Link wird aus der Antwort gelesen, als JSON mit dem Feld url oder als reiner Text.",
        menuItemFormat: "Auf %@ hochladen",
        uploadingHUD: "Wird hochgeladen…",
        uploadedFormat: "Auf %@ hochgeladen",
        failedHUD: "Das Hochladen ist fehlgeschlagen",
        rejectedFormat: "Der Server hat das Hochladen abgelehnt (HTTP %d)"
    )

    static let fr = CaptureUploadStrings(
        sectionTitle: "Envoi vers un serveur",
        enabledToggle: "Autoriser l’envoi vers un serveur",
        screenshotCaption: "Envoyez une capture d’écran vers un serveur. Le fichier est le corps d’une seule requête HTTPS POST, avec son type dans Content-Type.",
        recordingCaption: "Envoyez un enregistrement vers un serveur. Le fichier est le corps d’une seule requête HTTPS POST, avec son type dans Content-Type. Il est d’abord compressé sur ce Mac à moins de 100 Mo, comme pour les liens temporaires.",
        fileNameCaption: "Le nom du fichier est transmis dans l’en-tête X-File-Name, encodé en pourcentage hors ASCII.",
        addressLabel: "Adresse",
        addressInvalid: "Saisissez une adresse https:// complète.",
        parametersTitle: "Paramètres de requête",
        headersTitle: "En-têtes",
        namePlaceholder: "Nom",
        valuePlaceholder: "Valeur",
        addParameter: "Ajouter un paramètre",
        addHeader: "Ajouter un en-tête",
        removeRow: "Supprimer",
        headerNameInvalid: "Ce nom ne peut pas servir d’en-tête.",
        valuesStayCaption: "Les valeurs restent sur ce Mac. Une sauvegarde des réglages n’emporte que l’adresse et les noms.",
        copyLinkToggle: "Copier le lien après l’envoi",
        replyCaption: "Le lien est lu dans la réponse, en JSON avec un champ url ou en texte brut.",
        menuItemFormat: "Envoyer vers %@",
        uploadingHUD: "Envoi en cours…",
        uploadedFormat: "Envoyé vers %@",
        failedHUD: "L’envoi a échoué",
        rejectedFormat: "Le serveur a refusé l’envoi (HTTP %d)"
    )

    static let it = CaptureUploadStrings(
        sectionTitle: "Caricamento su un server",
        enabledToggle: "Consenti il caricamento su un server",
        screenshotCaption: "Invia uno screenshot a un server. Il file è il corpo di una singola richiesta HTTPS POST, con il tipo in Content-Type.",
        recordingCaption: "Invia una registrazione a un server. Il file è il corpo di una singola richiesta HTTPS POST, con il tipo in Content-Type. Viene prima compressa su questo Mac sotto i 100 MB, come per i link temporanei.",
        fileNameCaption: "Il nome del file viaggia nell’intestazione X-File-Name, con codifica percentuale fuori dall’ASCII.",
        addressLabel: "Indirizzo",
        addressInvalid: "Inserisci un indirizzo https:// completo.",
        parametersTitle: "Parametri della query",
        headersTitle: "Intestazioni",
        namePlaceholder: "Nome",
        valuePlaceholder: "Valore",
        addParameter: "Aggiungi parametro",
        addHeader: "Aggiungi intestazione",
        removeRow: "Rimuovi",
        headerNameInvalid: "Questo nome non può essere usato per un’intestazione.",
        valuesStayCaption: "I valori restano su questo Mac. Un backup delle impostazioni contiene solo l’indirizzo e i nomi.",
        copyLinkToggle: "Copia il link dopo il caricamento",
        replyCaption: "Il link viene letto dalla risposta, come JSON con un campo url o come testo semplice.",
        menuItemFormat: "Carica su %@",
        uploadingHUD: "Caricamento…",
        uploadedFormat: "Caricato su %@",
        failedHUD: "Caricamento non riuscito",
        rejectedFormat: "Il server ha rifiutato il caricamento (HTTP %d)"
    )

    static let ja = CaptureUploadStrings(
        sectionTitle: "サーバへのアップロード",
        enabledToggle: "サーバへのアップロードを許可",
        screenshotCaption: "スクリーンショットをサーバに送ります。ファイルは1回のHTTPS POSTリクエストの本文として送られ、種類はContent-Typeで示されます。",
        recordingCaption: "録画をサーバに送ります。ファイルは1回のHTTPS POSTリクエストの本文として送られ、種類はContent-Typeで示されます。録画は一時リンクと同様に、まずこのMacで100 MB未満に圧縮されます。",
        fileNameCaption: "ファイル名はX-File-Nameヘッダで送られ、ASCII以外の文字はパーセントエンコードされます。",
        addressLabel: "アドレス",
        addressInvalid: "https:// から始まる完全なアドレスを入力してください。",
        parametersTitle: "クエリパラメータ",
        headersTitle: "ヘッダ",
        namePlaceholder: "名前",
        valuePlaceholder: "値",
        addParameter: "パラメータを追加",
        addHeader: "ヘッダを追加",
        removeRow: "削除",
        headerNameInvalid: "この名前はヘッダに使えません。",
        valuesStayCaption: "値はこのMacに残ります。設定のバックアップにはアドレスと名前だけが含まれます。",
        copyLinkToggle: "アップロード後にリンクをコピー",
        replyCaption: "リンクは応答から読み取ります（urlフィールドを持つJSONまたはプレーンテキスト）。",
        menuItemFormat: "%@ にアップロード",
        uploadingHUD: "アップロード中…",
        uploadedFormat: "%@ にアップロードしました",
        failedHUD: "アップロードできませんでした",
        rejectedFormat: "サーバがアップロードを拒否しました（HTTP %d）"
    )

    static let ko = CaptureUploadStrings(
        sectionTitle: "서버에 업로드",
        enabledToggle: "서버에 업로드 허용",
        screenshotCaption: "스크린샷을 서버로 보냅니다. 파일은 HTTPS POST 요청 하나의 본문으로 전송되며, 종류는 Content-Type에 담깁니다.",
        recordingCaption: "녹화를 서버로 보냅니다. 파일은 HTTPS POST 요청 하나의 본문으로 전송되며, 종류는 Content-Type에 담깁니다. 녹화는 임시 링크와 마찬가지로 먼저 이 Mac에서 100MB 미만으로 압축됩니다.",
        fileNameCaption: "파일 이름은 X-File-Name 헤더로 전송되며, ASCII가 아닌 문자는 퍼센트 인코딩됩니다.",
        addressLabel: "주소",
        addressInvalid: "https://로 시작하는 전체 주소를 입력하세요.",
        parametersTitle: "쿼리 매개변수",
        headersTitle: "헤더",
        namePlaceholder: "이름",
        valuePlaceholder: "값",
        addParameter: "매개변수 추가",
        addHeader: "헤더 추가",
        removeRow: "제거",
        headerNameInvalid: "이 이름은 헤더에 사용할 수 없습니다.",
        valuesStayCaption: "값은 이 Mac에 남습니다. 설정 백업에는 주소와 이름만 포함됩니다.",
        copyLinkToggle: "업로드 후 링크 복사",
        replyCaption: "링크는 응답에서 읽어 옵니다(url 필드가 있는 JSON 또는 일반 텍스트).",
        menuItemFormat: "%@에 업로드",
        uploadingHUD: "업로드 중…",
        uploadedFormat: "%@에 업로드했습니다",
        failedHUD: "업로드하지 못했습니다",
        rejectedFormat: "서버가 업로드를 거부했습니다 (HTTP %d)"
    )

    static let zhHans = CaptureUploadStrings(
        sectionTitle: "上传到服务器",
        enabledToggle: "允许上传到服务器",
        screenshotCaption: "把截图发送到服务器。文件作为一次 HTTPS POST 请求的正文发送，类型写在 Content-Type 中。",
        recordingCaption: "把录制发送到服务器。文件作为一次 HTTPS POST 请求的正文发送，类型写在 Content-Type 中。录制会像临时链接一样，先在这台 Mac 上压缩到 100 MB 以内。",
        fileNameCaption: "文件名通过 X-File-Name 请求头发送，非 ASCII 字符会进行百分号编码。",
        addressLabel: "地址",
        addressInvalid: "请输入以 https:// 开头的完整地址。",
        parametersTitle: "查询参数",
        headersTitle: "请求头",
        namePlaceholder: "名称",
        valuePlaceholder: "值",
        addParameter: "添加参数",
        addHeader: "添加请求头",
        removeRow: "移除",
        headerNameInvalid: "此名称不能用作请求头。",
        valuesStayCaption: "值只保存在这台 Mac 上。设置备份只包含地址和名称。",
        copyLinkToggle: "上传后复制链接",
        replyCaption: "链接从响应中读取（带 url 字段的 JSON 或纯文本）。",
        menuItemFormat: "上传到 %@",
        uploadingHUD: "正在上传…",
        uploadedFormat: "已上传到 %@",
        failedHUD: "上传失败",
        rejectedFormat: "服务器拒绝了上传（HTTP %d）"
    )

    static let zhTW = CaptureUploadStrings(
        sectionTitle: "上傳到伺服器",
        enabledToggle: "允許上傳到伺服器",
        screenshotCaption: "把螢幕截圖傳送到伺服器。檔案作為一次 HTTPS POST 要求的內容傳送，類型寫在 Content-Type 中。",
        recordingCaption: "把錄製傳送到伺服器。檔案作為一次 HTTPS POST 要求的內容傳送，類型寫在 Content-Type 中。錄製會像暫時連結一樣，先在這台 Mac 上壓縮至 100 MB 以內。",
        fileNameCaption: "檔案名稱透過 X-File-Name 標頭傳送，非 ASCII 字元會進行百分比編碼。",
        addressLabel: "位址",
        addressInvalid: "請輸入以 https:// 開頭的完整位址。",
        parametersTitle: "查詢參數",
        headersTitle: "標頭",
        namePlaceholder: "名稱",
        valuePlaceholder: "值",
        addParameter: "加入參數",
        addHeader: "加入標頭",
        removeRow: "移除",
        headerNameInvalid: "此名稱不能用作標頭。",
        valuesStayCaption: "值只保存在這台 Mac 上。設定備份只包含位址和名稱。",
        copyLinkToggle: "上傳後複製連結",
        replyCaption: "連結從回應中讀取（含 url 欄位的 JSON 或純文字）。",
        menuItemFormat: "上傳到 %@",
        uploadingHUD: "正在上傳…",
        uploadedFormat: "已上傳到 %@",
        failedHUD: "上傳失敗",
        rejectedFormat: "伺服器拒絕了上傳（HTTP %d）"
    )

    static let zhHK = CaptureUploadStrings(
        sectionTitle: "上載到伺服器",
        enabledToggle: "允許上載到伺服器",
        screenshotCaption: "把螢幕截圖傳送到伺服器。檔案作為一次 HTTPS POST 要求的內容傳送，類型寫在 Content-Type 中。",
        recordingCaption: "把錄製傳送到伺服器。檔案作為一次 HTTPS POST 要求的內容傳送，類型寫在 Content-Type 中。錄製會像暫時連結一樣，先在這部 Mac 上壓縮至 100 MB 以內。",
        fileNameCaption: "檔案名稱透過 X-File-Name 標頭傳送，非 ASCII 字元會進行百分比編碼。",
        addressLabel: "位址",
        addressInvalid: "請輸入以 https:// 開頭的完整位址。",
        parametersTitle: "查詢參數",
        headersTitle: "標頭",
        namePlaceholder: "名稱",
        valuePlaceholder: "值",
        addParameter: "加入參數",
        addHeader: "加入標頭",
        removeRow: "移除",
        headerNameInvalid: "此名稱不能用作標頭。",
        valuesStayCaption: "值只保存在這部 Mac 上。設定備份只包含位址和名稱。",
        copyLinkToggle: "上載後複製連結",
        replyCaption: "連結從回應中讀取（含 url 欄位的 JSON 或純文字）。",
        menuItemFormat: "上載到 %@",
        uploadingHUD: "正在上載…",
        uploadedFormat: "已上載到 %@",
        failedHUD: "上載失敗",
        rejectedFormat: "伺服器拒絕了上載（HTTP %d）"
    )

    static let uk = CaptureUploadStrings(
        sectionTitle: "Завантаження на сервер",
        enabledToggle: "Дозволити завантаження на сервер",
        screenshotCaption: "Надсилайте знімок екрана на сервер. Файл є тілом одного запиту HTTPS POST, а його тип указано в Content-Type.",
        recordingCaption: "Надсилайте запис на сервер. Файл є тілом одного запиту HTTPS POST, а його тип указано в Content-Type. Запис спочатку стискається на цьому Mac до розміру менше 100 МБ, як і для тимчасових посилань.",
        fileNameCaption: "Ім’я файлу передається в заголовку X-File-Name; символи поза ASCII кодуються відсотками.",
        addressLabel: "Адреса",
        addressInvalid: "Введіть повну адресу, що починається з https://.",
        parametersTitle: "Параметри запиту",
        headersTitle: "Заголовки",
        namePlaceholder: "Назва",
        valuePlaceholder: "Значення",
        addParameter: "Додати параметр",
        addHeader: "Додати заголовок",
        removeRow: "Видалити",
        headerNameInvalid: "Цю назву не можна використати для заголовка.",
        valuesStayCaption: "Значення залишаються на цьому Mac. Резервна копія налаштувань містить лише адресу та назви.",
        copyLinkToggle: "Копіювати посилання після завантаження",
        replyCaption: "Посилання зчитується з відповіді: з JSON із полем url або з простого тексту.",
        menuItemFormat: "Завантажити на %@",
        uploadingHUD: "Завантаження…",
        uploadedFormat: "Завантажено на %@",
        failedHUD: "Не вдалося завантажити",
        rejectedFormat: "Сервер відхилив завантаження (HTTP %d)"
    )
}
