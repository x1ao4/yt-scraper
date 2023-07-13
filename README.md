# yt-scraper
使用 yt-scraper 可以从 YouTube 下载视频信息和封面图片。yt-scraper 可以通过 yt-dlp 和 jq 工具获取指定 YouTube 频道或播放列表的视频数据，包括频道或播放列表所有视频的上传日期、时长、视频标题、视频简介和封面图片。yt-scraper 会记录已经保存过信息的视频 ID，所以也可以用于订阅频道或播放列表，通过定时运行 yt-scraper 可以追踪下载更新的视频数据。

## 运行条件
- MacOS
  - 安装了必要的第三方工具：[yt-dlp](https://github.com/yt-dlp/yt-dlp) 和 jq。
- Windows
  - 安装了 Windows Subsystem for Linux (WSL)、Cygwin 或 Git for Windows。
  - 在 WSL、Cygwin 或 Git for Windows 中安装了必要的第三方工具：[yt-dlp](https://github.com/yt-dlp/yt-dlp) 和 jq。

## 使用方法（MacOS）
1. 将仓库克隆或下载到计算机上的一个目录中。
2. 根据需要，修改脚本中的参数：video_list_id、download_info 和 download_covers。
   - video_list_id：您想要处理的 YouTube 频道或播放列表的 ID。
   - download_info：是否下载视频信息（true 表示下载，false 表示不下载）。
   - download_covers：是否下载封面图片（true 表示下载，false 表示不下载）。
   
   注：YouTube 频道 ID 可以通过频道地址获取，`https://www.youtube.com/ID`，频道 ID 以 `@` 开头；YouTube 播放列表 ID 可以通过播放列表地址获取，`https://www.youtube.com/playlist?list=ID`，播放列表 ID 以 `PL` 开头。
3. 修改 `start.command` 中的路径，以指向您存放 `yt-scraper.sh` 脚本的目录。
4. 双击运行 `start.command` 脚本以执行 `yt-scraper.sh` 脚本。
5. 脚本将开始获取指定频道或播放列表内所有视频的视频信息（如果选择下载）和封面图片（如果选择下载），并将结果写入到同一目录下以指定频道或播放列表名称命名的文件夹内，脚本会创建一个名为 `infos.txt` 的文件用于存储视频信息；脚本会在这个文件夹中创建一个名为 `covers` 的子文件夹，用于存储下载的封面图片；它还会创建一个名为 `archive` 的子文件夹，用于存储已处理视频的 ID，以便在下次运行脚本时跳过这些视频。

## 注意事项
- 如果脚本无法连接到 YouTube 网站，请检查您的网络连接，并确保网站可以访问。
- 如果需要下载封面图片，请确保您的工作目录具有足够的存储空间。

## 特别说明
yt-scraper 默认为直接获取视频的上传日期、时长、视频标题、视频简介和封面图片，但是通过修改脚本，我们可以对这些内容进行自定义。

我在 customized-demo 中提供了两个示例脚本，分别用于获取 YouTube 频道 [DUST](https://www.youtube.com/@watchdust) 和 YouTube 播放列表[小姐不熙娣](https://www.youtube.com/playlist?list=PLih1-oWJUt3nj0IHCIUsm8JmH0KC13KGH)的视频数据，这两个脚本对上传日期、视频标题、视频简介都做了提取和重新处理的操作，并且重新定义了封面图片的保存名称。

在实际使用时，我们可能需要对获取的数据进行筛选和重组，由于频道或播放列表的内容差异，如果您有定制内容的需求，可能需要自己对脚本进行修改，以便只提取对您有用的数据进行保存。
<br>
<br>
<br>
# yt-scraper
yt-scraper allows you to download video information and cover images from YouTube. yt-scraper uses the yt-dlp and jq tools to obtain video data from a specified YouTube channel or playlist, including the upload date, duration, video title, video description, and cover image of all videos in the channel or playlist. yt-scraper records the video IDs that have been saved, so it can also be used to subscribe to channels or playlists. By running yt-scraper regularly, you can track and download updated video data.

## Requirements
- MacOS
  - Installed necessary third-party tools: [yt-dlp](https://github.com/yt-dlp/yt-dlp) and jq.
- Windows
  - Installed Windows Subsystem for Linux (WSL), Cygwin, or Git for Windows.
  - Installed necessary third-party tools in WSL, Cygwin, or Git for Windows: [yt-dlp](https://github.com/yt-dlp/yt-dlp) and jq.

## Usage (MacOS)
1. Clone or download the repository to a directory on your computer.
2. Modify the script parameters as needed: video_list_id, download_info, and download_covers.
   - video_list_id: The ID of the YouTube channel or playlist you want to process.
   - download_info: Whether to download video information (true means download, false means do not download).
   - download_covers: Whether to download cover images (true means download, false means do not download).
   
   Note: The YouTube channel ID can be found in the channel’s URL, which is in the format `https://www.youtube.com/ID`, where the channel ID starts with `@`. The YouTube playlist ID can be found in the playlist’s URL, which is in the format `https://www.youtube.com/playlist?list=ID`, where the playlist ID starts with `PL`.
3. Modify the path in `start.command` to point to the directory where you stored the `yt-scraper.sh` script.
4. Double-click the `start.command` script to run the `yt-scraper.sh` script.
5. The script will start retrieving all video information (if selected for download) and cover images (if selected for download) from the specified channel or playlist and write the results to a folder named after the specified channel or playlist in the same directory. The script will create a file named `infos.txt` to store video information; The script will create a subfolder named `covers` in this folder to store downloaded cover images; It will also create a subfolder named `archive` to store processed video IDs so that these videos can be skipped when running the script next time.

## Notes
- If the script cannot connect to the YouTube website, please check your network connection and make sure that the website is accessible.
- If you need to download cover images, please make sure that your working directory has enough storage space.

## Heads Up
yt-scraper defaults to directly obtaining video upload date, duration, video title, video description, and cover image, but by modifying the script we can customize these contents.

I provide two sample scripts in customized-demo for obtaining video data from YouTube channel [DUST](https://www.youtube.com/@watchdust) and YouTube playlist [小姐不熙娣](https://www.youtube.com/playlist?list=PLih1-oWJUt3nj0IHCIUsm8JmH0KC13KGH). These two scripts extract and reprocess upload date, video title, and video description and redefine the save name of cover images.

In actual use, we may need to filter and reorganize the data obtained. Due to differences in channel or playlist content, if you have custom content requirements, you may need to modify the script yourself in order to extract only useful data for saving.
